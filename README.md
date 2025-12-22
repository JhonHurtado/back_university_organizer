# 🎓 University Organizer - Backend API

[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue.svg)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18.0+-green.svg)](https://nodejs.org/)
[![Prisma](https://img.shields.io/badge/Prisma-5.0+-brightgreen.svg)](https://www.prisma.io/)
[![Express](https://img.shields.io/badge/Express-4.18+-lightgrey.svg)](https://expressjs.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Backend API RESTful para un sistema completo de gestión académica universitaria. Permite a los estudiantes organizar sus carreras, materias, calificaciones, horarios y más.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Stack Tecnológico](#-stack-tecnológico)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API Documentation](#-api-documentation)
- [Arquitectura](#-arquitectura)
- [Scripts Disponibles](#-scripts-disponibles)
- [Roadmap](#-roadmap)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

---

## ✨ Características

### 🔐 Autenticación y Seguridad
- ✅ Autenticación JWT con Access y Refresh Tokens
- ✅ OAuth 2.0 (Google)
- ✅ Gestión de sesiones con expiración
- ✅ Rate limiting por IP
- ✅ Helmet para headers de seguridad
- ✅ CORS configurado
- ✅ Gestión de clientes API

### 🎯 Gestión Académica (TIER 1 - MVP)
- ✅ **Carreras:** CRUD completo con estadísticas y soft delete
- ✅ **Semestres:** Organización de materias por semestres
- ✅ **Materias:** CRUD con prerequisitos y corequisitos
- ✅ **Inscripciones:** Sistema inteligente de inscripción con validaciones
- ✅ **Calificaciones:** Gestión de notas con cálculo automático de GPA
  - Soporte para múltiples escalas (0-5, 0-10, 0-100, 0-4 GPA, 1-7)
  - Cálculo de promedios ponderados
  - Conversión entre escalas

### 📅 Funcionalidades Principales (TIER 2)
- ✅ **Horarios:** Gestión de horarios con detección de conflictos
  - Vista semanal organizada
  - Excepciones de calendario
  - Múltiples tipos de eventos
- ✅ **Notificaciones:** Sistema completo de notificaciones
  - Categorización (SYSTEM, ACADEMIC, GRADE, SCHEDULE, etc.)
  - Estados (leído/no leído)
  - Expiración automática
- ✅ **Suscripciones y Pagos:** Sistema completo de monetización
  - Planes de suscripción con límites configurables
  - Procesamiento de pagos
  - Generación de facturas
  - Webhooks para gateway de pagos
  - Auto-renovación

### 🔄 Estado del Proyecto
```
✅ TIER 1 (CRÍTICO): 100% - MVP Completo
✅ TIER 2 (IMPORTANTE): 100% - Funcionalidad Principal Completa
⏳ TIER 3 (MODERADA): 0% - Mejoras Pendientes
⏳ TIER 4 (BAJA): 0% - Refinamiento Futuro
```

---

## 🛠️ Stack Tecnológico

### Core
- **Runtime:** Node.js 18+
- **Framework:** Express 4.18+
- **Lenguaje:** TypeScript 5.0+
- **Base de Datos:** PostgreSQL 14+
- **ORM:** Prisma 5.0+

### Seguridad
- **Autenticación:** JWT (jsonwebtoken)
- **Encriptación:** bcrypt
- **Headers:** Helmet
- **CORS:** cors
- **Rate Limiting:** express-rate-limit

### Validación
- **Esquemas:** Zod
- **Tipos:** TypeScript strict mode

### Desarrollo
- **Linting:** ESLint
- **Formatting:** Prettier
- **Hot Reload:** tsx (desarrollo)

---

## 📦 Requisitos

- Node.js 18.0 o superior
- PostgreSQL 14.0 o superior
- npm o yarn
- Git

---

## 🚀 Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/back_university_organizer.git
cd back_university_organizer
```

### 2. Instalar dependencias
```bash
npm install
```

### 3. Configurar variables de entorno
```bash
cp .env.example .env
```

Edita el archivo `.env` con tus configuraciones:
```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/university_organizer"

# JWT
JWT_SECRET="tu-super-secreto-seguro-aqui"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_SECRET="tu-refresh-secreto-seguro-aqui"
JWT_REFRESH_EXPIRES_IN="7d"

# OAuth Google
GOOGLE_CLIENT_ID="tu-google-client-id"
GOOGLE_CLIENT_SECRET="tu-google-client-secret"
GOOGLE_CALLBACK_URL="http://localhost:3000/api/auth/google/callback"

# Server
PORT=3000
NODE_ENV="development"

# CORS
ALLOWED_ORIGINS="http://localhost:5173,http://localhost:3000"

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 4. Configurar base de datos
```bash
# Generar cliente de Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# (Opcional) Poblar con datos de prueba
npm run prisma:seed
```

### 5. Iniciar servidor
```bash
# Desarrollo (con hot reload)
npm run dev

# Producción
npm run build
npm start
```

El servidor estará disponible en `http://localhost:3000`

---

## ⚙️ Configuración

### Variables de Entorno

| Variable | Descripción | Requerido | Default |
|----------|-------------|-----------|---------|
| `DATABASE_URL` | URL de conexión a PostgreSQL | ✅ | - |
| `JWT_SECRET` | Secret para tokens de acceso | ✅ | - |
| `JWT_EXPIRES_IN` | Tiempo de expiración del access token | ❌ | 15m |
| `JWT_REFRESH_SECRET` | Secret para refresh tokens | ✅ | - |
| `JWT_REFRESH_EXPIRES_IN` | Tiempo de expiración del refresh token | ❌ | 7d |
| `GOOGLE_CLIENT_ID` | Client ID de Google OAuth | ❌ | - |
| `GOOGLE_CLIENT_SECRET` | Client Secret de Google OAuth | ❌ | - |
| `GOOGLE_CALLBACK_URL` | URL de callback de Google OAuth | ❌ | - |
| `PORT` | Puerto del servidor | ❌ | 3000 |
| `NODE_ENV` | Entorno de ejecución | ❌ | development |
| `ALLOWED_ORIGINS` | Orígenes permitidos para CORS (separados por coma) | ❌ | * |
| `RATE_LIMIT_WINDOW_MS` | Ventana de tiempo para rate limiting (ms) | ❌ | 900000 |
| `RATE_LIMIT_MAX_REQUESTS` | Máximo de requests por ventana | ❌ | 100 |

### Escalas de Calificación Soportadas

El sistema soporta múltiples escalas de calificación:

| Escala | Rango | Región |
|--------|-------|--------|
| `FIVE` | 0.0 - 5.0 | Colombia, México |
| `TEN` | 0.0 - 10.0 | Argentina, España |
| `HUNDRED` | 0 - 100 | USA (porcentaje) |
| `FOUR_GPA` | 0.0 - 4.0 | USA (GPA) |
| `SEVEN` | 1.0 - 7.0 | Chile |

---

## 📁 Estructura del Proyecto

```
back_university_organizer/
├── prisma/                          # Configuración de Prisma
│   ├── schema.prisma               # Esquema de base de datos
│   └── migrations/                 # Migraciones
├── src/
│   ├── types/                      # Tipos y esquemas
│   │   └── schemas/                # Esquemas de validación Zod
│   │       ├── auth/               # Esquemas de autenticación
│   │       ├── careers/            # Esquemas de carreras
│   │       ├── grades/             # Esquemas de calificaciones
│   │       ├── notifications/      # Esquemas de notificaciones
│   │       ├── payments/           # Esquemas de pagos
│   │       ├── schedules/          # Esquemas de horarios
│   │       └── subscriptions/      # Esquemas de suscripciones
│   ├── services/                   # Lógica de negocio
│   │   ├── auth/                   # Servicios de autenticación
│   │   ├── careers/                # Servicios de carreras
│   │   ├── grades/                 # Servicios de calificaciones
│   │   ├── notifications/          # Servicios de notificaciones
│   │   ├── payments/               # Servicios de pagos
│   │   ├── schedules/              # Servicios de horarios
│   │   └── subscriptions/          # Servicios de suscripciones
│   ├── controllers/                # Controladores HTTP
│   │   ├── auth/                   # Controladores de autenticación
│   │   ├── careers/                # Controladores de carreras
│   │   ├── grades/                 # Controladores de calificaciones
│   │   ├── notifications/          # Controladores de notificaciones
│   │   ├── payments/               # Controladores de pagos
│   │   ├── schedules/              # Controladores de horarios
│   │   └── subscriptions/          # Controladores de suscripciones
│   ├── routes/                     # Definición de rutas
│   │   ├── auth/                   # Rutas de autenticación
│   │   ├── careers/                # Rutas de carreras
│   │   ├── grades/                 # Rutas de calificaciones
│   │   ├── notifications/          # Rutas de notificaciones
│   │   ├── payments/               # Rutas de pagos
│   │   ├── schedules/              # Rutas de horarios
│   │   ├── subscriptions/          # Rutas de suscripciones
│   │   └── index.routes.ts         # Agregador de rutas
│   ├── middleware/                 # Middlewares
│   │   ├── auth/                   # Middleware de autenticación
│   │   ├── rateLimiter/            # Middleware de rate limiting
│   │   └── errorHandler/           # Manejador de errores
│   ├── utils/                      # Utilidades
│   │   └── response/               # Utilidades de respuesta
│   ├── lib/                        # Librerías
│   │   └── prisma/                 # Cliente de Prisma
│   ├── config/                     # Configuraciones
│   └── index.ts                    # Punto de entrada
├── generated/                       # Archivos generados
│   └── prisma/                     # Cliente de Prisma generado
├── .env                            # Variables de entorno (no commitear)
├── .env.example                    # Ejemplo de variables de entorno
├── tsconfig.json                   # Configuración de TypeScript
├── package.json                    # Dependencias y scripts
├── ROADMAP.md                      # Roadmap del proyecto
└── README.md                       # Este archivo
```

---

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api
```

### Autenticación

Todos los endpoints protegidos requieren un token JWT en el header:
```
Authorization: Bearer <access_token>
```

### Endpoints Principales

#### 🔐 Autenticación
```http
POST   /api/auth/register              # Registrar usuario
POST   /api/auth/login                 # Login con email/password
POST   /api/auth/google                # Login con Google OAuth
POST   /api/auth/refresh               # Renovar access token
POST   /api/auth/logout                # Cerrar sesión
GET    /api/auth/me                    # Obtener usuario actual
```

#### 👤 Usuarios
```http
GET    /api/users                      # Listar usuarios
GET    /api/users/:id                  # Obtener usuario por ID
POST   /api/users                      # Crear usuario
PUT    /api/users/:id                  # Actualizar usuario
DELETE /api/users/:id                  # Eliminar usuario
GET    /api/users/:id/stats            # Estadísticas del usuario
```

#### 🎓 Carreras
```http
GET    /api/careers                    # Listar carreras del usuario
GET    /api/careers/:id                # Obtener carrera por ID
POST   /api/careers                    # Crear carrera
PUT    /api/careers/:id                # Actualizar carrera
DELETE /api/careers/:id                # Eliminar carrera (soft delete)
POST   /api/careers/:id/restore        # Restaurar carrera
GET    /api/careers/:id/stats          # Estadísticas de la carrera
```

#### 📚 Académico
```http
# Semestres
POST   /api/academic/semesters                              # Crear semestre
GET    /api/academic/semesters/career/:careerId             # Listar semestres de carrera
GET    /api/academic/semesters/:id                          # Obtener semestre
PUT    /api/academic/semesters/:id                          # Actualizar semestre
DELETE /api/academic/semesters/:id                          # Eliminar semestre

# Materias
POST   /api/academic/subjects                               # Crear materia
GET    /api/academic/subjects/semester/:semesterId          # Listar materias de semestre
GET    /api/academic/subjects/:id                           # Obtener materia
PUT    /api/academic/subjects/:id                           # Actualizar materia
DELETE /api/academic/subjects/:id                           # Eliminar materia
POST   /api/academic/subjects/:id/prerequisites             # Agregar prerequisito
POST   /api/academic/subjects/:id/corequisites              # Agregar corequisito
DELETE /api/academic/subjects/:subjectId/prerequisites/:prerequisiteId  # Eliminar prerequisito

# Períodos Académicos
POST   /api/academic/periods                                # Crear período
GET    /api/academic/periods/career/:careerId               # Listar períodos de carrera
GET    /api/academic/periods/current                        # Obtener período actual
PUT    /api/academic/periods/:id                            # Actualizar período

# Inscripciones
POST   /api/academic/enrollments                            # Inscribir en materia
GET    /api/academic/enrollments/period/:periodId           # Listar inscripciones de período
GET    /api/academic/enrollments/validate/:subjectId        # Validar si puede inscribirse
PUT    /api/academic/enrollments/:id                        # Actualizar inscripción
```

#### 📊 Calificaciones
```http
POST   /api/grades                                          # Crear nota por corte
GET    /api/grades/enrollment/:enrollmentId                 # Obtener notas de inscripción
PUT    /api/grades/:id                                      # Actualizar nota
DELETE /api/grades/:id                                      # Eliminar nota
POST   /api/grades/:id/items                                # Agregar item de calificación
PUT    /api/grades/items/:itemId                            # Actualizar item
DELETE /api/grades/items/:itemId                            # Eliminar item
GET    /api/grades/career/:careerId/history                 # Historial de notas
GET    /api/grades/career/:careerId/gpa                     # Calcular GPA
```

#### 📅 Horarios
```http
POST   /api/schedules                                       # Crear horario
GET    /api/schedules/weekly                                # Vista semanal del usuario
GET    /api/schedules/enrollment/:enrollmentId              # Horarios de una materia
GET    /api/schedules/conflicts                             # Detectar conflictos
GET    /api/schedules/:id                                   # Obtener horario
PUT    /api/schedules/:id                                   # Actualizar horario
DELETE /api/schedules/:id                                   # Eliminar horario
POST   /api/schedules/:id/exceptions                        # Crear excepción
```

#### 🔔 Notificaciones
```http
GET    /api/notifications                                   # Listar notificaciones
GET    /api/notifications/unread/count                      # Contador de no leídas
GET    /api/notifications/:id                               # Obtener notificación
POST   /api/notifications                                   # Crear notificación
PUT    /api/notifications/:id                               # Actualizar notificación
PUT    /api/notifications/:id/read                          # Marcar como leída
PUT    /api/notifications/read-all                          # Marcar todas como leídas
DELETE /api/notifications/:id                               # Eliminar notificación
DELETE /api/notifications/read-all                          # Eliminar todas las leídas
```

#### 💳 Suscripciones y Pagos
```http
# Planes
GET    /api/subscriptions/plans                             # Listar planes
GET    /api/subscriptions/plans/:id                         # Obtener plan
POST   /api/subscriptions/plans                             # Crear plan (admin)
PUT    /api/subscriptions/plans/:id                         # Actualizar plan (admin)
DELETE /api/subscriptions/plans/:id                         # Eliminar plan (admin)

# Suscripciones
GET    /api/subscriptions                                   # Listar suscripciones del usuario
GET    /api/subscriptions/active                            # Obtener suscripción activa
GET    /api/subscriptions/:id                               # Obtener suscripción
POST   /api/subscriptions                                   # Crear suscripción
PUT    /api/subscriptions/:id                               # Actualizar suscripción
PUT    /api/subscriptions/:id/plan                          # Cambiar plan
POST   /api/subscriptions/:id/cancel                        # Cancelar suscripción
POST   /api/subscriptions/:id/renew                         # Renovar suscripción
GET    /api/subscriptions/features/:featureName/validate    # Validar acceso a feature
GET    /api/subscriptions/limits/careers                    # Validar límite de carreras
GET    /api/subscriptions/limits/subjects/:careerId         # Validar límite de materias

# Pagos
GET    /api/payments                                        # Listar pagos del usuario
GET    /api/payments/:id                                    # Obtener pago
POST   /api/payments                                        # Crear pago
PUT    /api/payments/:id                                    # Actualizar pago
POST   /api/payments/:id/process                            # Procesar pago
POST   /api/payments/:id/refund                             # Reembolsar pago
POST   /api/payments/webhooks                               # Webhook de payment gateway

# Facturas
GET    /api/payments/invoices                               # Listar facturas del usuario
GET    /api/payments/invoices/:id                           # Obtener factura
POST   /api/payments/invoices                               # Crear factura
PUT    /api/payments/invoices/:id                           # Actualizar factura
POST   /api/payments/invoices/:id/mark-paid                 # Marcar como pagada
DELETE /api/payments/invoices/:id                           # Eliminar factura
GET    /api/payments/invoices/generate-number               # Generar número de factura
```

### Formato de Respuestas

#### Respuesta Exitosa
```json
{
  "success": true,
  "message": "Operación exitosa",
  "data": {
    // Datos de respuesta
  }
}
```

#### Respuesta de Error
```json
{
  "success": false,
  "message": "Descripción del error",
  "error": "ERROR_CODE",
  "details": {
    // Detalles adicionales (validación, etc.)
  }
}
```

### Códigos de Estado HTTP

| Código | Descripción |
|--------|-------------|
| `200` | OK - Operación exitosa |
| `201` | Created - Recurso creado exitosamente |
| `400` | Bad Request - Datos inválidos |
| `401` | Unauthorized - No autenticado |
| `403` | Forbidden - Sin permisos |
| `404` | Not Found - Recurso no encontrado |
| `409` | Conflict - Conflicto con estado actual |
| `422` | Unprocessable Entity - Error de validación |
| `429` | Too Many Requests - Rate limit excedido |
| `500` | Internal Server Error - Error del servidor |

---

## 🏗️ Arquitectura

### Patrón de Capas

El proyecto sigue una arquitectura en capas:

```
┌─────────────────────────────────────┐
│         Cliente (Frontend)          │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Routes (Express Router)         │  ← Definición de endpoints
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Middleware (Auth, Validation)   │  ← Autenticación, validación
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Controllers (HTTP Handlers)     │  ← Manejo de requests/responses
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Services (Business Logic)       │  ← Lógica de negocio
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Prisma ORM (Data Access)        │  ← Acceso a datos
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     PostgreSQL Database             │  ← Base de datos
└─────────────────────────────────────┘
```

### Patrón de Implementación

Cada módulo sigue el mismo patrón:

**1. Schema (Validación con Zod)**
```typescript
// types/schemas/[module]/[module].schemas.ts
export const createItemSchema = z.object({
  name: z.string().min(2),
  // ...
});

export type CreateItemInput = z.infer<typeof createItemSchema>;
```

**2. Service (Lógica de Negocio)**
```typescript
// services/[module]/[module].service.ts
class ItemService {
  async create(data: CreateItemInput) {
    // Validaciones de negocio
    // Operaciones con base de datos
    return await database.item.create({ data });
  }
}
```

**3. Controller (Manejo HTTP)**
```typescript
// controllers/[module]/[module].controller.ts
export async function create(req: Request, res: Response) {
  try {
    const data = createItemSchema.parse(req.body);
    const result = await itemService.create(data);
    return sendSuccess({ res, data: result });
  } catch (error) {
    return sendError({ res, error });
  }
}
```

**4. Routes (Endpoints)**
```typescript
// routes/[module]/[module].routes.ts
router.post("/", requireAuth, itemController.create);
```

### Principios de Diseño

- **Single Responsibility:** Cada clase/función tiene una única responsabilidad
- **Dependency Injection:** Servicios como singletons exportados
- **Type Safety:** TypeScript en modo estricto
- **Validation First:** Validación con Zod antes de procesar
- **Error Handling:** Manejo consistente de errores
- **Soft Delete:** Eliminación lógica con campo `state`

---

## 🔧 Scripts Disponibles

```bash
# Desarrollo
npm run dev              # Iniciar servidor en modo desarrollo (hot reload)

# Producción
npm run build           # Compilar TypeScript a JavaScript
npm start              # Iniciar servidor en producción

# Base de datos
npm run prisma:generate # Generar cliente de Prisma
npm run prisma:migrate  # Ejecutar migraciones
npm run prisma:studio   # Abrir Prisma Studio (GUI)
npm run prisma:seed     # Poblar base de datos con datos de prueba

# Testing (cuando se implemente)
npm test               # Ejecutar tests
npm run test:watch     # Ejecutar tests en modo watch
npm run test:coverage  # Generar reporte de cobertura

# Linting y Formatting
npm run lint           # Ejecutar ESLint
npm run lint:fix       # Corregir errores de ESLint
npm run format         # Formatear código con Prettier
```

---

## 🗺️ Roadmap

### ✅ Completado (54%)

**TIER 1 - MVP (100%)**
- ✅ Autenticación y Sesiones
- ✅ Gestión de Carreras
- ✅ Materias e Inscripciones
- ✅ Sistema de Calificaciones

**TIER 2 - Funcionalidad Principal (100%)**
- ✅ Gestión de Horarios
- ✅ Sistema de Notificaciones
- ✅ Suscripciones y Pagos

### 🔄 En Desarrollo (0%)

**TIER 3 - Mejoras**
- ⏳ Gestión de Profesores
- ⏳ Preferencias de Usuario
- ⏳ Sistema de Menús Dinámico

**TIER 4 - Refinamiento**
- ⏳ Activity Logs
- ⏳ Verificación de Email
- ⏳ Features Académicas Avanzadas

Ver [ROADMAP.md](ROADMAP.md) para detalles completos.

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Convenciones de Código

- Seguir el patrón establecido (Schema → Service → Controller → Routes)
- Usar TypeScript estricto
- Validar con Zod
- Mantener cobertura de tests
- Documentar funciones complejas
- Usar nombres descriptivos

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👥 Autores

- **Tu Nombre** - *Desarrollo inicial* - [@tu-usuario](https://github.com/tu-usuario)

---

## 🙏 Agradecimientos

- Prisma por el excelente ORM
- Express por el framework minimalista
- Zod por la validación type-safe
- Comunidad de TypeScript

---

## 📞 Soporte

Si tienes alguna pregunta o problema:

- 📧 Email: tu-email@ejemplo.com
- 🐛 Issues: [GitHub Issues](https://github.com/tu-usuario/back_university_organizer/issues)
- 📖 Documentación: [Wiki](https://github.com/tu-usuario/back_university_organizer/wiki)

---

**Hecho con ❤️ y ☕**
