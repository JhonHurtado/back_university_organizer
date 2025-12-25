# Guía de Almacenamiento de Sesión

## Resumen

El sistema de autenticación ahora guarda **todos** los datos retornados por el backend al hacer login/register, incluyendo tokens, información del usuario, suscripción y menú.

## Estructura de Datos del Backend

Cuando el usuario hace login, el backend retorna:

```json
{
  "success": true,
  "message": "Sesión iniciada exitosamente",
  "data": {
    "access_token": "eyJhbGci...",
    "refresh_token": "eyJhbGci...",
    "token_type": "Bearer",
    "expires_in": 900,
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "emailVerified": false
    },
    "subscription": null,
    "menu": [...]
  }
}
```

## Estrategia de Almacenamiento

### 1. **FlutterSecureStorage** - Para Tokens (Seguridad)
Almacena datos sensibles de forma encriptada:
- `access_token` - Token de acceso JWT
- `refresh_token` - Token para renovar el access_token

### 2. **SharedPreferences** - Para Datos de Usuario
Almacena datos no sensibles localmente:
- `token_type` - Tipo de token (Bearer)
- `expires_in` - Tiempo de expiración en segundos
- `token_expiration` - Fecha/hora de expiración calculada
- `user_data` - Información completa del usuario (JSON)
- `subscription_data` - Información de suscripción (JSON, nullable)
- `menu_data` - Array de items del menú (JSON)

## Archivos Modificados/Creados

### 1. **Nuevos Modelos**
- `lib/models/menu_item.dart` - Modelo para items del menú
- `lib/models/menu_item.g.dart` - Código generado por json_serializable
- `lib/models/subscription.dart` - Ya existía, contiene modelo de suscripción

### 2. **AuthResponse Actualizado**
**Archivo**: `lib/services/auth_service.dart`

Ahora incluye todos los campos del backend:
```dart
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final User user;
  final Subscription? subscription;
  final List<MenuItem> menu;
}
```

### 3. **AuthProvider Actualizado**
**Archivo**: `lib/providers/auth_provider.dart`

**Nuevos Campos**:
- `String _tokenType` - Tipo de token
- `int _expiresIn` - Tiempo de expiración
- `DateTime? _tokenExpiration` - Fecha de expiración calculada
- `Subscription? _subscription` - Suscripción del usuario
- `List<MenuItem> _menu` - Menú del usuario

**Métodos Actualizados**:

#### `initialize()`
Carga todos los datos al iniciar la app:
```dart
// Carga tokens desde FlutterSecureStorage
_accessToken = await _secureStorage.read(key: _accessTokenKey);
_refreshToken = await _secureStorage.read(key: _refreshTokenKey);

// Carga datos desde SharedPreferences
final prefs = await SharedPreferences.getInstance();
_tokenType = prefs.getString(_tokenTypeKey) ?? 'Bearer';
_expiresIn = prefs.getInt(_expiresInKey) ?? 900;
_user = User.fromJson(jsonDecode(prefs.getString(_userKey)));
_subscription = Subscription.fromJson(jsonDecode(prefs.getString(_subscriptionKey)));
_menu = (jsonDecode(prefs.getString(_menuKey)) as List)
    .map((m) => MenuItem.fromJson(m)).toList();
```

#### `setAuthData()`
Guarda todos los datos después del login:
```dart
Future<void> setAuthData({
  required String accessToken,
  required String refreshToken,
  required User user,
  String tokenType = 'Bearer',
  int expiresIn = 900,
  Subscription? subscription,
  List<MenuItem> menu = const [],
}) async {
  // Guarda tokens en FlutterSecureStorage
  await _secureStorage.write(key: _accessTokenKey, value: accessToken);
  await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

  // Calcula expiración
  final expiration = DateTime.now().add(Duration(seconds: expiresIn));

  // Guarda datos en SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenTypeKey, tokenType);
  await prefs.setInt(_expiresInKey, expiresIn);
  await prefs.setInt(_tokenExpirationKey, expiration.millisecondsSinceEpoch);
  await prefs.setString(_userKey, jsonEncode(user.toJson()));
  await prefs.setString(_subscriptionKey, jsonEncode(subscription?.toJson()));
  await prefs.setString(_menuKey, jsonEncode(menu.map((m) => m.toJson()).toList()));
}
```

#### `logout()`
Limpia todos los datos:
```dart
// Limpia FlutterSecureStorage
await _secureStorage.delete(key: _accessTokenKey);
await _secureStorage.delete(key: _refreshTokenKey);

// Limpia SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.remove(_tokenTypeKey);
await prefs.remove(_expiresInKey);
await prefs.remove(_tokenExpirationKey);
await prefs.remove(_userKey);
await prefs.remove(_subscriptionKey);
await prefs.remove(_menuKey);
```

#### Nuevos Métodos:
```dart
// Verifica si el token expiró
bool isTokenExpired() {
  if (_tokenExpiration == null) return false;
  return DateTime.now().isAfter(_tokenExpiration!);
}

// Obtiene tiempo restante hasta expiración
Duration? getTokenRemainingTime() {
  if (_tokenExpiration == null) return null;
  return _tokenExpiration!.difference(DateTime.now());
}
```

### 4. **Pantallas Actualizadas**

#### Login Screen
**Archivo**: `lib/screens/auth/login_screen.dart`

```dart
await context.read<AuthProvider>().setAuthData(
  accessToken: authResponse.accessToken,
  refreshToken: authResponse.refreshToken,
  tokenType: authResponse.tokenType,
  expiresIn: authResponse.expiresIn,
  user: authResponse.user,
  subscription: authResponse.subscription,
  menu: authResponse.menu,
);
```

#### Register Screen
**Archivo**: `lib/screens/auth/register_screen.dart`

Mismo patrón que login screen.

## Acceso a los Datos

### Desde cualquier widget con Provider:

```dart
// Obtener el provider
final authProvider = context.watch<AuthProvider>();

// Acceder a los datos
String? token = authProvider.accessToken;
User? user = authProvider.currentUser;
Subscription? subscription = authProvider.subscription;
List<MenuItem> menu = authProvider.menu;

// Verificar expiración del token
bool expired = authProvider.isTokenExpired();
Duration? remaining = authProvider.getTokenRemainingTime();
```

## Flujo de Autenticación

### 1. **Login/Register**
```
Usuario → Login → Backend responde con todos los datos →
AuthResponse parseado → ApiClient actualizado con token →
AuthProvider guarda todos los datos → Usuario autenticado
```

### 2. **Inicio de App**
```
App inicia → AuthProvider.initialize() →
Carga tokens de FlutterSecureStorage →
Carga datos de SharedPreferences →
Si token válido → Usuario autenticado
```

### 3. **Logout**
```
Usuario → Logout → AuthProvider.logout() →
Limpia FlutterSecureStorage →
Limpia SharedPreferences →
ApiClient.clearToken() →
Usuario no autenticado
```

## Seguridad

- ✅ **Tokens encriptados** - FlutterSecureStorage usa encriptación nativa del OS
- ✅ **Datos de usuario local** - SharedPreferences para datos no sensibles
- ✅ **Token expiration tracking** - Calcula y guarda tiempo de expiración
- ✅ **Limpieza completa al logout** - Elimina todos los datos guardados

## Persistencia

Los datos persisten entre:
- ✅ Cierres de app
- ✅ Reinicios de dispositivo
- ✅ Actualizaciones de app (según configuración del OS)

## Notas Importantes

1. **FlutterSecureStorage** es más seguro que SharedPreferences para tokens
2. **SharedPreferences** es más rápido y adecuado para datos no sensibles
3. El token expira en **15 minutos** (900 segundos) según la respuesta del backend
4. La app verifica automáticamente si el token expiró usando `isTokenExpired()`
5. El menú del usuario se guarda para construir navegación dinámica
6. La suscripción puede ser `null` si el usuario no tiene plan premium

## Próximos Pasos Sugeridos

1. Implementar auto-refresh del token antes de que expire
2. Usar el menú guardado para construir navegación dinámica
3. Mostrar estado de suscripción en la UI
4. Agregar indicador visual de tiempo restante del token
