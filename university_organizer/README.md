# 🎓 University Organizer - Aplicación Flutter

Aplicación móvil para organizar la vida académica universitaria con Clean Architecture y diseño profesional.

---

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Estructura de Carpetas](#-estructura-de-carpetas)
- [Configuración Inicial](#-configuración-inicial)
- [APIs y Servicios](#-apis-y-servicios)
- [Paleta de Colores](#-paleta-de-colores)
- [Creación de Interfaces](#-creación-de-interfaces)
- [Buenas Prácticas](#-buenas-prácticas)

---

## 🏗 Arquitectura

La aplicación sigue **Clean Architecture** con separación clara de responsabilidades:

```
Presentation Layer (UI)
       ↓
Domain Layer (Business Logic)
       ↓
Data Layer (API & Storage)
```

### Capas

1. **Presentation** - UI y estado de la aplicación
2. **Domain** - Lógica de negocio y casos de uso
3. **Data** - Acceso a datos (API, almacenamiento local)
4. **Core** - Utilidades compartidas

---

## 📁 Estructura de Carpetas

```
lib/
├── core/                           # Funcionalidades compartidas
│   ├── constants/                  # Constantes de la app
│   │   └── api_constants.dart      # URLs, credenciales, endpoints
│   ├── errors/                     # Manejo de errores
│   │   ├── exceptions.dart         # Excepciones personalizadas
│   │   └── failures.dart           # Failures para Either
│   ├── network/                    # Configuración de red
│   │   ├── api_client.dart         # Cliente Dio configurado
│   │   └── auth_interceptor.dart   # Interceptor de autenticación
│   ├── themes/                     # Temas visuales
│   │   ├── app_colors.dart         # Paleta de colores
│   │   ├── app_dimensions.dart     # Espaciados y tamaños
│   │   └── app_theme.dart          # Tema general
│   └── utils/                      # Utilidades
│       └── validators.dart         # Validadores de formularios
│
├── data/                           # Capa de datos
│   ├── datasources/                # Fuentes de datos
│   │   ├── local/                  # Almacenamiento local
│   │   │   └── auth_local_datasource.dart
│   │   └── remote/                 # API remota
│   │       ├── service.interface.dart      # ⭐ Interfaz de servicios API
│   │       └── auth_remote_datasource.dart # Implementación auth
│   ├── models/                     # Modelos de datos
│   │   ├── auth_response_model.dart
│   │   └── user_model.dart
│   └── repositories/               # Implementaciones de repositorios
│       └── auth_repository_impl.dart
│
├── domain/                         # Capa de dominio
│   ├── entities/                   # Entidades de negocio
│   │   ├── auth_response.dart
│   │   └── user.dart
│   ├── repositories/               # Contratos de repositorios
│   │   └── auth_repository.dart
│   └── usecases/                   # Casos de uso
│       └── auth/
│           ├── login_usecase.dart
│           ├── register_usecase.dart
│           └── logout_usecase.dart
│
└── presentation/                   # Capa de presentación
    ├── providers/                  # Providers de Riverpod
    │   ├── auth_providers.dart     # Providers de autenticación
    │   └── auth_state_notifier.dart
    ├── screens/                    # Pantallas
    │   ├── auth/
    │   │   ├── login_screen_fresh.dart
    │   │   └── register_screen_fresh.dart
    │   └── home/
    │       └── home_screen_fresh.dart
    └── widgets/                    # Widgets reutilizables
        └── common/
            ├── custom_button.dart
            ├── custom_text_field.dart
            ├── error_message.dart
            └── loading_indicator.dart
```

### 📂 Propósito de Cada Carpeta

#### **core/**
Contiene código compartido en toda la aplicación:
- **constants/**: URLs, credenciales del cliente, endpoints de API
- **errors/**: Sistema de manejo de errores consistente
- **network/**: Configuración de Dio, interceptores HTTP
- **themes/**: Paleta de colores, dimensiones, tema dark
- **utils/**: Validadores, helpers, extensiones

#### **data/**
Maneja el acceso a datos:
- **datasources/local/**: FlutterSecureStorage para tokens
- **datasources/remote/**: Llamadas HTTP al backend
- **models/**: Serialización JSON con `json_serializable`
- **repositories/**: Implementa interfaces del domain

#### **domain/**
Lógica de negocio pura (sin dependencias de Flutter):
- **entities/**: Objetos de dominio inmutables
- **repositories/**: Interfaces abstractas
- **usecases/**: Casos de uso individuales

#### **presentation/**
UI y gestión de estado:
- **providers/**: Providers de Riverpod para DI
- **screens/**: Pantallas completas de la app
- **widgets/**: Componentes reutilizables

---

## ⚙️ Configuración Inicial

### 1. Requisitos Previos

```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
```

### 2. Instalación de Dependencias

```bash
flutter pub get
```

### 3. Generar Código (JSON Serialization)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configuración de Backend

Editar `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://TU_IP:3030/api/v1';
static const String clientId = 'TU_CLIENT_ID';
static const String clientSecret = 'TU_CLIENT_SECRET';
```

### 5. Ejecutar la App

```bash
flutter run
```

---

## 🌐 APIs y Servicios

### Arquitectura de Servicios

La aplicación usa **service.interface.dart** como punto central para todas las llamadas API:

```dart
// lib/data/datasources/remote/service.interface.dart
abstract class ServiceInterface {
  // Servicios de Autenticación
  Future<Response> login({required String email, required String password});
  Future<Response> register({...});
  Future<Response> refreshToken(String refreshToken);
  Future<Response> logout();

  // Agregar más servicios aquí según se necesiten
}
```

### Flujo de una Petición API

```
1. UI llama a → StateNotifier
2. StateNotifier llama a → UseCase
3. UseCase llama a → Repository (interface)
4. Repository llama a → RemoteDataSource
5. RemoteDataSource llama a → ServiceInterface
6. ServiceInterface usa → ApiClient (Dio)
7. AuthInterceptor agrega → Headers/Body según endpoint
```

### Credenciales del Cliente

**Importante:** Las credenciales del cliente (`client_id`, `client_secret`) se envían en el **body** de las peticiones de autenticación, NO en headers.

```dart
// ✅ CORRECTO (en service.interface.dart)
Future<Response> login({required String email, required String password}) {
  return _apiClient.post(
    ApiConstants.login,
    data: {
      'client_id': ApiConstants.clientId,      // ← En body
      'client_secret': ApiConstants.clientSecret, // ← En body
      'email': email,
      'password': password,
    },
  );
}

// ❌ INCORRECTO
// No enviar credenciales en headers para auth
```

### Endpoints Disponibles

Definidos en `api_constants.dart`:

```dart
// Autenticación
static const String login = '/auth/login';
static const String register = '/auth/register';
static const String refresh = '/auth/refresh';
static const String logout = '/auth/logout';
static const String logoutAll = '/auth/logout-all';
static const String me = '/auth/me';
static const String googleAuth = '/auth/google';
```

### AuthInterceptor

El interceptor agrega automáticamente el token Bearer para rutas protegidas:

```dart
// Rutas de autenticación: NO llevan Bearer token
// Rutas protegidas: Llevan Bearer token automáticamente

if (!_isAuthEndpoint(options.path)) {
  options.headers['Authorization'] = 'Bearer $accessToken';
}
```

---

## 🎨 Paleta de Colores

### Colores Principales

```dart
// Colores de fondo
background   = #0A0E27  // Azul oscuro profundo
card         = #16213E  // Azul marino oscuro

// Colores de texto
foreground   = #F5F5F5  // Blanco suave
mutedForeground = #9CA3AF  // Gris claro

// Color primario
primary      = #4A7C96  // Azul acero suave (profesional)

// Colores de estado
success      = #059669  // Verde esmeralda profesional
warning      = #D97706  // Ámbar profesional
destructive  = #DC2626  // Rojo profesional
info         = #3B82F6  // Azul información

// Colores para gráficos
chart1       = #4A7C96  // Azul acero
chart2       = #7C3AED  // Púrpura profesional
chart3       = #D97706  // Ámbar
chart4       = #059669  // Verde
chart5       = #DC2626  // Rojo

// Bordes y campos
border       = #374151  // Gris oscuro
input        = #1F2937  // Gris azulado oscuro
```

### Uso de Colores

```dart
// En widgets
Container(
  color: AppColors.card,
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.border),
    color: AppColors.primary.withValues(alpha: 0.1), // 10% opacity
  ),
)

// En texto
Text(
  'Título',
  style: TextStyle(color: AppColors.foreground),
)

// Gradientes simples
gradient: LinearGradient(
  colors: AppColors.primaryGradient, // [#4A7C96, #5B8BA8]
)
```

### Filosofía de Diseño

- **Profesional y Elegante**: Colores sutiles sin neón
- **Legible**: Alto contraste entre fondo y texto
- **Consistente**: Usar siempre AppColors, nunca colores hardcoded
- **Accesible**: Cumple con WCAG 2.1 AA

---

## 🛠 Creación de Interfaces

### Agregar un Nuevo Servicio API

#### 1. Definir el Endpoint en `api_constants.dart`

```dart
class ApiConstants {
  // ... endpoints existentes

  // Nuevos endpoints de calificaciones
  static const String gradesBase = '/grades';
  static const String getGrades = '$gradesBase';
  static const String createGrade = '$gradesBase';
  static const String updateGrade = '$gradesBase/:id';
  static const String deleteGrade = '$gradesBase/:id';
}
```

#### 2. Agregar Métodos en `service.interface.dart`

```dart
abstract class ServiceInterface {
  // ... métodos existentes

  // Servicios de Calificaciones
  Future<Response> getGrades();
  Future<Response> createGrade(Map<String, dynamic> data);
  Future<Response> updateGrade(String id, Map<String, dynamic> data);
  Future<Response> deleteGrade(String id);
}

class ServiceInterfaceImpl implements ServiceInterface {
  // ... implementaciones existentes

  @override
  Future<Response> getGrades() {
    return _apiClient.get(ApiConstants.getGrades);
  }

  @override
  Future<Response> createGrade(Map<String, dynamic> data) {
    return _apiClient.post(ApiConstants.createGrade, data: data);
  }

  @override
  Future<Response> updateGrade(String id, Map<String, dynamic> data) {
    return _apiClient.put(
      ApiConstants.updateGrade.replaceAll(':id', id),
      data: data,
    );
  }

  @override
  Future<Response> deleteGrade(String id) {
    return _apiClient.delete(
      ApiConstants.deleteGrade.replaceAll(':id', id),
    );
  }
}
```

#### 3. Crear Modelos de Datos

```dart
// lib/domain/entities/grade.dart
class Grade {
  final String id;
  final String subjectName;
  final double score;
  final DateTime date;

  const Grade({
    required this.id,
    required this.subjectName,
    required this.score,
    required this.date,
  });
}

// lib/data/models/grade_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade_model.freezed.dart';
part 'grade_model.g.dart';

@freezed
class GradeModel with _$GradeModel {
  const factory GradeModel({
    required String id,
    required String subjectName,
    required double score,
    required DateTime date,
  }) = _GradeModel;

  factory GradeModel.fromJson(Map<String, dynamic> json) =>
      _$GradeModelFromJson(json);
}
```

#### 4. Crear DataSource

```dart
// lib/data/datasources/remote/grades_remote_datasource.dart
abstract class GradesRemoteDataSource {
  Future<List<GradeModel>> getGrades();
  Future<GradeModel> createGrade(Map<String, dynamic> data);
  // ... más métodos
}

class GradesRemoteDataSourceImpl implements GradesRemoteDataSource {
  final ServiceInterface _serviceInterface;

  GradesRemoteDataSourceImpl(this._serviceInterface);

  @override
  Future<List<GradeModel>> getGrades() async {
    try {
      final response = await _serviceInterface.getGrades();

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => GradeModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener calificaciones',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado');
    }
  }

  // ... implementar otros métodos
}
```

#### 5. Crear Repository

```dart
// lib/domain/repositories/grades_repository.dart
abstract class GradesRepository {
  Future<Either<Failure, List<Grade>>> getGrades();
  Future<Either<Failure, Grade>> createGrade(Map<String, dynamic> data);
}

// lib/data/repositories/grades_repository_impl.dart
class GradesRepositoryImpl implements GradesRepository {
  final GradesRemoteDataSource remoteDataSource;

  GradesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Grade>>> getGrades() async {
    try {
      final grades = await remoteDataSource.getGrades();
      return Right(grades);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado'));
    }
  }
}
```

#### 6. Crear UseCase

```dart
// lib/domain/usecases/grades/get_grades_usecase.dart
class GetGradesUseCase {
  final GradesRepository repository;

  GetGradesUseCase(this.repository);

  Future<Either<Failure, List<Grade>>> call() async {
    return await repository.getGrades();
  }
}
```

#### 7. Crear Providers

```dart
// lib/presentation/providers/grades_providers.dart
final gradesRemoteDataSourceProvider = Provider<GradesRemoteDataSource>((ref) {
  final serviceInterface = ref.watch(serviceInterfaceProvider);
  return GradesRemoteDataSourceImpl(serviceInterface);
});

final gradesRepositoryProvider = Provider<GradesRepository>((ref) {
  final remoteDataSource = ref.watch(gradesRemoteDataSourceProvider);
  return GradesRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getGradesUseCaseProvider = Provider<GetGradesUseCase>((ref) {
  final repository = ref.watch(gradesRepositoryProvider);
  return GetGradesUseCase(repository);
});
```

#### 8. Crear StateNotifier

```dart
// lib/presentation/providers/grades_state_notifier.dart
@freezed
class GradesState with _$GradesState {
  const factory GradesState({
    @Default([]) List<Grade> grades,
    @Default(false) bool isLoading,
    String? error,
  }) = _GradesState;
}

class GradesStateNotifier extends StateNotifier<GradesState> {
  final GetGradesUseCase getGradesUseCase;

  GradesStateNotifier(this.getGradesUseCase) : super(const GradesState());

  Future<void> loadGrades() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getGradesUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (grades) => state = state.copyWith(
        isLoading: false,
        grades: grades,
      ),
    );
  }
}

final gradesStateNotifierProvider =
    StateNotifierProvider<GradesStateNotifier, GradesState>((ref) {
  final useCase = ref.watch(getGradesUseCaseProvider);
  return GradesStateNotifier(useCase);
});
```

#### 9. Usar en UI

```dart
class GradesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesState = ref.watch(gradesStateNotifierProvider);

    return Scaffold(
      body: gradesState.isLoading
          ? LoadingIndicator()
          : ListView.builder(
              itemCount: gradesState.grades.length,
              itemBuilder: (context, index) {
                final grade = gradesState.grades[index];
                return ListTile(
                  title: Text(grade.subjectName),
                  subtitle: Text(grade.score.toString()),
                );
              },
            ),
    );
  }
}
```

---

## ✅ Buenas Prácticas

### 1. Gestión de Estado
- ✅ Usar Riverpod para DI y gestión de estado
- ✅ StateNotifier para estado complejo
- ✅ Provider para dependencias

### 2. Manejo de Errores
- ✅ Usar Either<Failure, Success> en repositorios
- ✅ Excepciones tipadas (ServerException, NetworkException, etc.)
- ✅ Mostrar mensajes de error amigables en UI

### 3. Código Limpio
- ✅ Nombres descriptivos en español para variables de negocio
- ✅ Comentarios en español
- ✅ Constantes en lugar de valores hardcoded
- ✅ Widget const donde sea posible

### 4. Performance
- ✅ Sin animaciones innecesarias
- ✅ Lazy loading en listas largas
- ✅ Caché de imágenes
- ✅ Disponer controllers en dispose()

### 5. Seguridad
- ✅ Tokens en FlutterSecureStorage
- ✅ HTTPS en producción
- ✅ Validación de inputs
- ✅ No hardcodear credenciales en código

### 6. Testing
- ✅ Unit tests para UseCases
- ✅ Widget tests para UI
- ✅ Mocks para repositorios

---

## 📚 Dependencias Principales

```yaml
dependencies:
  # Estado y DI
  flutter_riverpod: ^2.6.1

  # Network
  dio: ^5.7.0
  pretty_dio_logger: ^1.4.0

  # Almacenamiento
  flutter_secure_storage: ^9.2.4

  # Programación Funcional
  dartz: ^0.10.1

  # Serialización
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

---

## 🚀 Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Limpiar proyecto
flutter clean

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Ver dispositivos disponibles
flutter devices
```

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisar este README
2. Verificar estructura de carpetas
3. Revisar ejemplos de código en la app
4. Consultar documentación de Flutter

---

**Última actualización:** Diciembre 2025
**Versión:** 1.0.0
**Estado:** ✅ Producción Ready
