# University Organizer - Mobile App

Una aplicación móvil Flutter para organizar tu vida universitaria. Gestiona tus carreras, materias, horarios, calificaciones y más, todo en un solo lugar.

## Características

- ✅ Gestión de múltiples carreras universitarias
- 📚 Organización de materias por semestre
- 📊 Seguimiento de calificaciones y cálculo de promedios
- 📅 Horarios de clase con recordatorios
- 👨‍🏫 Gestión de profesores y sus datos de contacto
- 🔔 Sistema de notificaciones
- 📈 Análisis de rendimiento académico
- 🌙 Modo oscuro
- 🌐 Soporte multiidioma (Español/Inglés)
- 💳 Sistema de suscripciones con diferentes planes

## Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos (User, Career, Subject, etc.)
├── screens/                  # Pantallas de la aplicación
│   ├── auth/                # Pantallas de autenticación
│   ├── home/                # Pantalla principal
│   ├── careers/             # Gestión de carreras
│   ├── subjects/            # Gestión de materias
│   ├── grades/              # Gestión de calificaciones
│   ├── schedule/            # Gestión de horarios
│   └── profile/             # Perfil y configuración
├── widgets/                  # Widgets reutilizables
│   ├── common/              # Widgets comunes (botones, inputs, etc.)
│   └── cards/               # Cards personalizadas
├── services/                 # Servicios de API y lógica de negocio
│   ├── api/                 # Servicios de API
│   └── storage/             # Servicios de almacenamiento local
├── providers/                # Providers para gestión de estado
├── utils/                    # Utilidades y helpers
│   ├── validators/          # Validadores de formularios
│   └── helpers/             # Funciones auxiliares
├── constants/                # Constantes de la aplicación
│   ├── app_constants.dart   # Constantes generales
│   ├── app_routes.dart      # Rutas de navegación
│   └── app_theme.dart       # Tema y colores
└── l10n/                     # Archivos de localización
    ├── app_en.arb           # Traducciones en inglés
    └── app_es.arb           # Traducciones en español
```

## Requisitos Previos

- Flutter SDK (>=3.10.4)
- Dart SDK
- Android Studio / VS Code
- Backend API corriendo en `http://localhost:3030`

## Instalación

1. Clona el repositorio:
```bash
git clone <repository-url>
cd back_university_organizer/university_organizer
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Genera los archivos de localización:
```bash
flutter gen-l10n
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Configuración

### Backend API

La URL base del backend se configura en `lib/constants/app_constants.dart`:

```dart
static const String apiBaseUrl = 'http://localhost:3030';
```

Para producción, actualiza esta URL con la dirección de tu servidor.

### Credenciales OAuth

Actualiza las credenciales del cliente OAuth en `lib/constants/app_constants.dart`:

```dart
static const String oauthClientId = 'flutter-app';
static const String oauthClientSecret = 'your-client-secret-here';
```

## Dependencias Principales

- **provider**: Gestión de estado
- **dio**: Cliente HTTP para llamadas a la API
- **go_router**: Navegación
- **shared_preferences**: Almacenamiento local
- **flutter_secure_storage**: Almacenamiento seguro (tokens)
- **table_calendar**: Calendario
- **fl_chart**: Gráficos y analíticas
- **flutter_form_builder**: Construcción de formularios

## Estructura de Datos

La aplicación consume las siguientes APIs del backend:

### Autenticación
- `POST /auth/register` - Registro de usuario
- `POST /auth/login` - Inicio de sesión
- `POST /auth/google` - Autenticación con Google
- `POST /auth/refresh` - Renovar token
- `POST /auth/logout` - Cerrar sesión
- `GET /auth/me` - Obtener usuario actual

### Carreras
- `GET /careers` - Listar carreras
- `POST /careers` - Crear carrera
- `GET /careers/:id` - Obtener carrera
- `PUT /careers/:id` - Actualizar carrera
- `DELETE /careers/:id` - Eliminar carrera

### Materias
- `GET /academic/subjects` - Listar materias
- `POST /academic/subjects` - Crear materia
- `GET /academic/subjects/:id` - Obtener materia
- `PUT /academic/subjects/:id` - Actualizar materia
- `DELETE /academic/subjects/:id` - Eliminar materia

### Calificaciones
- `GET /grades` - Listar calificaciones
- `POST /grades` - Crear calificación
- `PUT /grades/:id` - Actualizar calificación
- `DELETE /grades/:id` - Eliminar calificación

### Horarios
- `GET /schedules` - Listar horarios
- `POST /schedules` - Crear horario
- `PUT /schedules/:id` - Actualizar horario
- `DELETE /schedules/:id` - Eliminar horario

### Notificaciones
- `GET /notifications` - Listar notificaciones
- `PUT /notifications/:id/read` - Marcar como leída

### Analíticas
- `GET /analytics/grades` - Analíticas de calificaciones
- `GET /analytics/performance` - Analíticas de rendimiento

## Temas y Estilos

La aplicación soporta modo claro y oscuro. Los colores principales son:

- **Primary**: Azul (#2563EB)
- **Secondary**: Púrpura (#7C3AED)
- **Accent**: Verde (#10B981)
- **Error**: Rojo (#EF4444)

## Localización

La aplicación soporta español e inglés. Para agregar un nuevo idioma:

1. Crea un archivo `app_[código_idioma].arb` en `lib/l10n/`
2. Copia las claves de `app_en.arb` y traduce los valores
3. Ejecuta `flutter gen-l10n`

## Testing

Para ejecutar los tests:

```bash
flutter test
```

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contribuir

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto es privado y no está licenciado para uso público.

## Soporte

Para reportar bugs o solicitar nuevas funcionalidades, por favor crea un issue en el repositorio.

---

Desarrollado con ❤️ usando Flutter
