# Estructura de Carpetas - University Organizer App

## Índice
- [Visión General](#visión-general)
- [Arquitectura](#arquitectura)
- [Estructura de Carpetas](#estructura-de-carpetas)
- [Convenciones de Nomenclatura](#convenciones-de-nomenclatura)
- [Flujo de Datos](#flujo-de-datos)
- [Mejores Prácticas](#mejores-prácticas)

---

## Visión General

Este proyecto Flutter sigue una **arquitectura limpia (Clean Architecture)** con separación clara de responsabilidades, lo que facilita el mantenimiento, las pruebas y la escalabilidad del código.

### Principios Fundamentales
- **Separación de Responsabilidades**: Cada capa tiene un propósito específico
- **Independencia de Frameworks**: La lógica de negocio no depende de Flutter
- **Testabilidad**: Cada capa puede ser probada de forma independiente
- **Independencia de la UI**: La interfaz puede cambiar sin afectar la lógica
- **Independencia de la Base de Datos**: Se puede cambiar el origen de datos fácilmente

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│              (UI, Widgets, State Management)             │
│                    presentation/                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                         │
│           (Business Logic, Use Cases, Entities)          │
│                     domain/                              │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│        (Repositories, Data Sources, Models)              │
│                      data/                               │
└─────────────────────────────────────────────────────────┘
```

---

## Estructura de Carpetas

```
lib/
├── core/                           # Código compartido en toda la app
│   ├── constants/                  # Constantes globales
│   │   ├── api_constants.dart      # URLs, endpoints
│   │   ├── app_constants.dart      # Constantes de la app
│   │   └── string_constants.dart   # Strings reutilizables
│   │
│   ├── themes/                     # Temas y estilos
│   │   ├── app_theme.dart          # Tema principal
│   │   ├── colors.dart             # Paleta de colores
│   │   ├── text_styles.dart        # Estilos de texto
│   │   └── dimensions.dart         # Dimensiones y espaciados
│   │
│   ├── utils/                      # Utilidades y helpers
│   │   ├── date_formatter.dart     # Formateo de fechas
│   │   ├── validators.dart         # Validadores de formularios
│   │   ├── extensions/             # Extension methods
│   │   │   ├── string_extension.dart
│   │   │   ├── date_extension.dart
│   │   │   └── context_extension.dart
│   │   └── helpers/
│   │       ├── storage_helper.dart
│   │       └── encryption_helper.dart
│   │
│   ├── errors/                     # Manejo de errores
│   │   ├── exceptions.dart         # Excepciones personalizadas
│   │   ├── failures.dart           # Clases Failure
│   │   └── error_handler.dart      # Manejador global de errores
│   │
│   └── network/                    # Configuración de red
│       ├── api_client.dart         # Cliente HTTP (Dio, http)
│       ├── interceptors.dart       # Interceptores de peticiones
│       └── network_info.dart       # Verificación de conectividad
│
├── data/                           # Capa de Datos
│   ├── models/                     # Modelos de datos (JSON <-> Dart)
│   │   ├── user_model.dart
│   │   ├── schedule_model.dart
│   │   ├── grade_model.dart
│   │   └── subject_model.dart
│   │
│   ├── repositories/               # Implementación de repositorios
│   │   ├── user_repository_impl.dart
│   │   ├── schedule_repository_impl.dart
│   │   └── grade_repository_impl.dart
│   │
│   └── datasources/                # Fuentes de datos
│       ├── remote/                 # API/Backend
│       │   ├── user_remote_datasource.dart
│       │   ├── schedule_remote_datasource.dart
│       │   └── grade_remote_datasource.dart
│       │
│       └── local/                  # Base de datos local, SharedPreferences
│           ├── user_local_datasource.dart
│           ├── database_helper.dart
│           └── cache_manager.dart
│
├── domain/                         # Capa de Dominio (Lógica de Negocio)
│   ├── entities/                   # Entidades del negocio
│   │   ├── user.dart
│   │   ├── schedule.dart
│   │   ├── grade.dart
│   │   └── subject.dart
│   │
│   ├── repositories/               # Contratos de repositorios (interfaces)
│   │   ├── user_repository.dart
│   │   ├── schedule_repository.dart
│   │   └── grade_repository.dart
│   │
│   └── usecases/                   # Casos de uso (lógica de negocio)
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── register_usecase.dart
│       │
│       ├── schedule/
│       │   ├── get_schedule_usecase.dart
│       │   ├── create_schedule_usecase.dart
│       │   └── update_schedule_usecase.dart
│       │
│       └── grades/
│           ├── get_grades_usecase.dart
│           ├── calculate_gpa_usecase.dart
│           └── predict_grade_usecase.dart
│
├── presentation/                   # Capa de Presentación (UI)
│   ├── screens/                    # Pantallas de la aplicación
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── dashboard_screen.dart
│   │   │
│   │   ├── schedule/
│   │   │   ├── schedule_list_screen.dart
│   │   │   ├── schedule_detail_screen.dart
│   │   │   └── schedule_form_screen.dart
│   │   │
│   │   ├── grades/
│   │   │   ├── grades_list_screen.dart
│   │   │   ├── grade_detail_screen.dart
│   │   │   └── gpa_calculator_screen.dart
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                    # Widgets reutilizables
│   │   ├── common/                 # Widgets comunes
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   └── empty_state_widget.dart
│   │   │
│   │   ├── schedule/               # Widgets específicos de horarios
│   │   │   ├── schedule_card.dart
│   │   │   └── schedule_calendar.dart
│   │   │
│   │   └── grades/                 # Widgets específicos de calificaciones
│   │       ├── grade_card.dart
│   │       └── gpa_chart.dart
│   │
│   ├── providers/                  # State Management (Provider, Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── schedule_provider.dart
│   │   ├── grade_provider.dart
│   │   └── theme_provider.dart
│   │
│   └── bloc/                       # State Management (BLoC)
│       ├── auth/
│       │   ├── auth_bloc.dart
│       │   ├── auth_event.dart
│       │   └── auth_state.dart
│       │
│       ├── schedule/
│       │   ├── schedule_bloc.dart
│       │   ├── schedule_event.dart
│       │   └── schedule_state.dart
│       │
│       └── grade/
│           ├── grade_bloc.dart
│           ├── grade_event.dart
│           └── grade_state.dart
│
├── config/                         # Configuración de la aplicación
│   ├── routes/                     # Configuración de rutas
│   │   ├── app_routes.dart         # Definición de rutas
│   │   └── route_generator.dart    # Generador de rutas
│   │
│   └── environment/                # Variables de entorno
│       ├── env_config.dart         # Configuración de entornos
│       ├── dev_config.dart         # Desarrollo
│       ├── staging_config.dart     # Staging
│       └── prod_config.dart        # Producción
│
├── services/                       # Servicios globales
│   ├── notification_service.dart   # Notificaciones push
│   ├── analytics_service.dart      # Analytics (Firebase, etc.)
│   ├── auth_service.dart           # Autenticación
│   └── storage_service.dart        # Almacenamiento local
│
└── main.dart                       # Punto de entrada de la aplicación

assets/                             # Recursos estáticos (fuera de lib/)
├── images/                         # Imágenes
│   ├── logo.png
│   ├── backgrounds/
│   └── icons/
│
├── fonts/                          # Fuentes personalizadas
│   ├── Roboto-Regular.ttf
│   └── Roboto-Bold.ttf
│
├── icons/                          # Iconos personalizados
│   └── app_icons.svg
│
└── animations/                     # Animaciones (Lottie, Rive)
    └── loading_animation.json

test/                               # Tests
├── unit/                           # Tests unitarios
│   ├── usecases/
│   ├── repositories/
│   └── models/
│
├── widget/                         # Tests de widgets
│   ├── screens/
│   └── widgets/
│
└── integration/                    # Tests de integración
    └── app_test.dart
```

---

## Convenciones de Nomenclatura

### Archivos
- **Snake case**: `user_repository.dart`, `login_screen.dart`
- **Sufijos descriptivos**:
  - `_screen.dart` para pantallas
  - `_widget.dart` para widgets
  - `_model.dart` para modelos
  - `_bloc.dart`, `_event.dart`, `_state.dart` para BLoC
  - `_provider.dart` para Providers
  - `_repository.dart` para repositorios
  - `_usecase.dart` para casos de uso

### Clases
- **PascalCase**: `UserRepository`, `LoginScreen`, `AuthBloc`
- **Nombres descriptivos**: La clase debe describir su propósito

### Variables y Funciones
- **camelCase**: `userName`, `getUserData()`, `isLoading`
- **Nombres significativos**: Evitar abreviaciones innecesarias

### Constantes
- **lowerCamelCase** (recomendado en Dart): `apiBaseUrl`, `maxRetries`
- O **SCREAMING_SNAKE_CASE**: `API_BASE_URL`, `MAX_RETRIES`

---

## Flujo de Datos

### Ejemplo: Obtener lista de calificaciones

```dart
1. UI (Screen) solicita datos
   ┌─────────────────────────┐
   │  GradesListScreen       │
   │  - Muestra lista        │
   └───────────┬─────────────┘
               │
               ▼
2. State Management coordina
   ┌─────────────────────────┐
   │  GradeBloc/Provider     │
   │  - Maneja estado UI     │
   └───────────┬─────────────┘
               │
               ▼
3. Use Case ejecuta lógica de negocio
   ┌─────────────────────────┐
   │  GetGradesUseCase       │
   │  - Valida               │
   │  - Aplica reglas        │
   └───────────┬─────────────┘
               │
               ▼
4. Repository abstrae fuente de datos
   ┌─────────────────────────┐
   │  GradeRepository        │
   │  - Decide fuente        │
   └───────────┬─────────────┘
               │
               ▼
5. DataSource obtiene datos
   ┌─────────────────────────┐
   │  GradeRemoteDataSource  │
   │  - API call             │
   └───────────┬─────────────┘
               │
               ▼
6. Model convierte JSON a Entity
   ┌─────────────────────────┐
   │  GradeModel.fromJson()  │
   │  - Parsea datos         │
   └─────────────────────────┘
```

---

## Mejores Prácticas

### 1. Capa de Dominio
```dart
// domain/entities/user.dart
// Entidades puras sin dependencias de Flutter
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// domain/repositories/user_repository.dart
// Interfaces, no implementaciones
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, void>> updateUser(User user);
}

// domain/usecases/get_user_usecase.dart
// Un caso de uso = una acción
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
```

### 2. Capa de Datos
```dart
// data/models/user_model.dart
// Modelo extiende entidad y añade serialización
class UserModel extends User {
  UserModel({
    required String id,
    required String name,
    required String email,
  }) : super(id: id, name: name, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// data/repositories/user_repository_impl.dart
// Implementación del repositorio
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final user = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### 3. Capa de Presentación
```dart
// presentation/screens/home/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return LoadingIndicator();
          } else if (state is UserLoaded) {
            return UserProfile(user: state.user);
          } else if (state is UserError) {
            return ErrorWidget(message: state.message);
          }
          return Container();
        },
      ),
    );
  }
}

// presentation/widgets/common/loading_indicator.dart
class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
```

### 4. Inyección de Dependencias
```dart
// main.dart
void main() {
  // Setup service locator (GetIt)
  setupDependencies();
  runApp(MyApp());
}

void setupDependencies() {
  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => NetworkInfo());

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserUseCase(sl()));

  // BLoC
  sl.registerFactory(() => UserBloc(getUserUseCase: sl()));
}
```

### 5. Organización de Imports
```dart
// 1. Imports de Dart
import 'dart:async';
import 'dart:convert';

// 2. Imports de Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Imports de paquetes externos
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Imports del proyecto
import 'package:university_organizer/core/constants/api_constants.dart';
import 'package:university_organizer/domain/entities/user.dart';
```

---

## Ventajas de esta Estructura

### Escalabilidad
- Fácil agregar nuevas funcionalidades sin afectar código existente
- Estructura clara para equipos grandes

### Mantenibilidad
- Código organizado y fácil de encontrar
- Cambios localizados en capas específicas

### Testabilidad
- Cada capa puede testearse independientemente
- Fácil crear mocks y stubs

### Reutilización
- Widgets y utilidades compartibles
- Lógica de negocio independiente de la UI

### Colaboración
- Múltiples desarrolladores pueden trabajar simultáneamente
- Reducción de conflictos en control de versiones

---

## Recursos Adicionales

### Documentación
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

### Paquetes Recomendados
- **State Management**: `flutter_bloc`, `provider`, `riverpod`
- **Networking**: `dio`, `http`
- **Local Storage**: `shared_preferences`, `hive`, `sqflite`
- **Dependency Injection**: `get_it`, `injectable`
- **Routing**: `go_router`, `auto_route`
- **JSON Serialization**: `json_serializable`, `freezed`
- **Error Handling**: `dartz` (Either, Option)

---

## Notas Finales

Esta estructura es una guía, no una regla estricta. Puedes adaptarla según las necesidades específicas de tu proyecto:

- **Proyectos pequeños**: Puedes simplificar eliminando capas
- **Proyectos medianos**: Usa la estructura tal como está
- **Proyectos grandes**: Considera modularizar por features

**Ejemplo de estructura por features:**
```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── schedule/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── grades/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── core/
```

---

Desarrollado para University Organizer App
Última actualización: Diciembre 2025
