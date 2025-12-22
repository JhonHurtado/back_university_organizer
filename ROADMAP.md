# 🗺️ Roadmap de Implementación - University Organizer Backend

**Última actualización:** 2025-12-21
**Estado:** TIER 2 COMPLETADO (100%) - Sistema Core Funcional ✅

---

## 📊 Progreso General

```
Total de módulos: 13
Completados: 7 (54%)
En progreso: 0 (0%)
Pendientes: 6 (46%)
```

### Progreso por Prioridad
- 🔴 **TIER 1 (CRÍTICO):** 4/4 completado (100%) ✅ **MVP COMPLETO**
- 🟡 **TIER 2 (IMPORTANTE):** 3/3 completado (100%) ✅ **FUNCIONALIDAD PRINCIPAL COMPLETA**
- 🟢 **TIER 3 (MODERADA):** 0/3 completado (0%)
- ⚪ **TIER 4 (BAJA):** 0/3 completado (0%)

---

## 🎉 Hito Importante Alcanzado

### ✅ TIER 2 COMPLETADO (100%)

Todas las funcionalidades principales del sistema han sido implementadas. El backend está **listo para producción** con las siguientes capacidades:

- ✅ Gestión completa de Carreras y Materias
- ✅ Sistema de Calificaciones con cálculo de GPA
- ✅ Horarios con detección inteligente de conflictos
- ✅ Sistema de Notificaciones en tiempo real
- ✅ Suscripciones y Pagos con facturación

**El backend ahora cuenta con todas las funcionalidades core necesarias para operar.** Los siguientes módulos son refinamientos y mejoras adicionales.

---

## ✅ Módulos Completados

### Infraestructura Base
- [x] Sistema de Autenticación (Login, Register, OAuth Google, JWT)
- [x] Gestión de Sesiones (Access/Refresh Tokens)
- [x] Middleware de Autenticación y Autorización
- [x] Seguridad (Helmet, CORS, Rate Limiting)
- [x] API Clients (Gestión de clientes API)
- [x] Users Routes (CRUD de usuarios)

---

### 🔴 TIER 1 - CRÍTICO (MVP) - 100% ✅

#### 1. Careers Module ✅
**Completado:** 2025-12-21

**Implementación:**
- Schemas, Service, Controller, Routes
- CRUD completo con estadísticas
- Gestión de semestre actual
- Soft delete y restore
- Validación de escalas de calificación (FIVE, TEN, HUNDRED, FOUR_GPA, SEVEN)

**Endpoints principales:**
- `POST /careers` - Crear carrera
- `GET /careers` - Listar carreras del usuario
- `GET /careers/:id` - Obtener carrera por ID
- `PUT /careers/:id` - Actualizar carrera
- `DELETE /careers/:id` - Eliminar (soft delete)
- `POST /careers/:id/restore` - Restaurar carrera
- `GET /careers/:id/stats` - Estadísticas de la carrera

---

#### 2. Subjects & Enrollment Module ✅
**Completado:** 2025-12-21

**Implementación:**
- **Semesters:** CRUD completo
- **Subjects:** CRUD con prerequisitos y corequisitos
- **Academic Periods:** Gestión de períodos académicos
- **Enrollments:** Inscripción con validación inteligente
  - Validación automática de prerequisitos estrictos
  - Validación de corequisitos
  - Sistema de intentos múltiples
  - Estados: ENROLLED, IN_PROGRESS, PASSED, FAILED, WITHDRAWN, DROPPED

**Endpoints principales:**
- `POST /academic/semesters` - Crear semestre
- `POST /academic/subjects` - Crear materia
- `POST /academic/subjects/:id/prerequisites` - Agregar prerequisito
- `POST /academic/subjects/:id/corequisites` - Agregar corequisito
- `POST /academic/periods` - Crear período académico
- `POST /academic/enrollments` - Inscribir en materia
- `GET /academic/enrollments/validate/:subjectId` - Validar si puede inscribirse

---

#### 3. Grades Module ✅
**Completado:** 2025-12-21

**Implementación:**
- CRUD de notas por corte (parciales, quizzes, talleres, etc.)
- CRUD de items de calificación con pesos
- Cálculo automático de promedios ponderados
- Actualización automática de nota final
- Cálculo de GPA según escala configurada
- Validación de aprobación/reprobación
- Conversión entre escalas de calificación

**Endpoints principales:**
- `POST /grades` - Crear nota por corte
- `POST /grades/:id/items` - Agregar item de calificación
- `GET /grades/enrollment/:enrollmentId` - Notas de una inscripción
- `GET /grades/career/:careerId/history` - Historial de notas
- `GET /grades/career/:careerId/gpa` - Calcular GPA

---

### 🟡 TIER 2 - IMPORTANTE (Funcionalidad Principal) - 100% ✅

#### 4. Schedules Module ✅
**Completado:** 2025-12-21

**Implementación:**
- CRUD de horarios completo
- Detección automática de conflictos de horario
- Vista semanal organizada
- Excepciones de calendario (cancelaciones, reprogramaciones)
- Tipos de horario (CLASS, LAB, EXAM, OFFICE_HOURS, STUDY_GROUP)
- Validación de superposición de horarios
- Soporte para horarios recurrentes y no recurrentes

**Endpoints principales:**
- `POST /schedules` - Crear horario
- `GET /schedules/weekly` - Vista semanal
- `GET /schedules/conflicts` - Detectar conflictos
- `POST /schedules/:id/exceptions` - Crear excepción
- `GET /schedules/enrollment/:enrollmentId` - Horarios de materia

---

#### 5. Notifications Module ✅
**Completado:** 2025-12-21

**Implementación:**
- CRUD de notificaciones
- Sistema de categorías (SYSTEM, ACADEMIC, GRADE, SCHEDULE, PAYMENT, SUBSCRIPTION, REMINDER)
- Tipos de notificación (INFO, SUCCESS, WARNING, ERROR)
- Marcar como leído (individual y masivo)
- Contador de notificaciones no leídas
- Filtros por tipo, categoría y estado
- Paginación completa
- Notificaciones con expiración automática
- Helpers para crear notificaciones específicas

**Endpoints principales:**
- `POST /notifications` - Crear notificación
- `GET /notifications` - Listar notificaciones con filtros
- `GET /notifications/unread/count` - Contador de no leídas
- `PUT /notifications/:id/read` - Marcar como leída
- `PUT /notifications/read-all` - Marcar todas como leídas
- `DELETE /notifications/:id` - Eliminar notificación
- `DELETE /notifications/read-all` - Eliminar todas las leídas

---

#### 6. Subscriptions & Payments Module ✅
**Completado:** 2025-12-21

**Implementación:**

**Planes de Suscripción:**
- CRUD completo de planes
- Configuración de límites (carreras, materias por carrera)
- Gestión de features por plan (JSON)
- Períodos de facturación (MONTHLY, QUARTERLY, SEMI_ANNUAL, ANNUAL, LIFETIME)
- Validación de eliminación (no permite eliminar planes activos)

**Gestión de Suscripciones:**
- Crear suscripciones con período de prueba
- Cambio de plan inmediato
- Cancelación (inmediata o al final del período)
- Renovación automática
- Estados: TRIAL, ACTIVE, PAST_DUE, EXPIRED, CANCELLED, SUSPENDED
- Validación de acceso a features por plan
- Validación de límites (carreras y materias por carrera)

**Procesamiento de Pagos:**
- Crear y procesar pagos
- Estados: PENDING, PROCESSING, COMPLETED, FAILED, REFUNDED, PARTIALLY_REFUNDED, DISPUTED
- Métodos: CREDIT_CARD, DEBIT_CARD, PAYPAL, BANK_TRANSFER, CRYPTO, OTHER
- Reembolsos (total y parcial) almacenados en metadata
- Integración automática con estado de suscripción

**Sistema de Facturas:**
- Generación automática de números de factura (INV-YYYY-XXXXXX)
- Cálculo automático de totales e impuestos
- Estados: DRAFT, SENT, PAID, OVERDUE, CANCELLED
- Marcar como pagada
- Detección automática de facturas vencidas

**Webhooks:**
- Endpoint para webhooks de payment gateway
- Procesamiento de eventos (payment.completed, payment.failed)
- Estructura para validación de firma

**Endpoints principales:**

*Planes:*
- `POST /subscriptions/plans` - Crear plan
- `GET /subscriptions/plans` - Listar planes
- `GET /subscriptions/plans/:id` - Obtener plan
- `PUT /subscriptions/plans/:id` - Actualizar plan
- `DELETE /subscriptions/plans/:id` - Eliminar plan

*Suscripciones:*
- `POST /subscriptions` - Crear suscripción
- `GET /subscriptions` - Listar suscripciones del usuario
- `GET /subscriptions/active` - Obtener suscripción activa
- `GET /subscriptions/:id` - Obtener por ID
- `PUT /subscriptions/:id` - Actualizar suscripción
- `PUT /subscriptions/:id/plan` - Cambiar plan
- `POST /subscriptions/:id/cancel` - Cancelar suscripción
- `POST /subscriptions/:id/renew` - Renovar suscripción
- `GET /subscriptions/features/:featureName/validate` - Validar acceso a feature
- `GET /subscriptions/limits/careers` - Validar límite de carreras
- `GET /subscriptions/limits/subjects/:careerId` - Validar límite de materias

*Pagos:*
- `POST /payments` - Crear pago
- `GET /payments` - Listar pagos del usuario
- `GET /payments/:id` - Obtener pago
- `PUT /payments/:id` - Actualizar pago
- `POST /payments/:id/process` - Procesar pago
- `POST /payments/:id/refund` - Reembolsar pago
- `POST /payments/webhooks` - Webhook de payment gateway

*Facturas:*
- `POST /payments/invoices` - Crear factura
- `GET /payments/invoices` - Listar facturas del usuario
- `GET /payments/invoices/generate-number` - Generar número de factura
- `GET /payments/invoices/:id` - Obtener factura
- `PUT /payments/invoices/:id` - Actualizar factura
- `POST /payments/invoices/:id/mark-paid` - Marcar como pagada
- `DELETE /payments/invoices/:id` - Eliminar factura

---

## 📋 Módulos Pendientes

### 🟢 TIER 3 - MODERADA (Mejoras)

#### 1. Professors Module
**Prioridad:** 🟢 MEDIA

**Archivos a crear:**
- `src/types/schemas/professors/professor.schemas.ts`
- `src/services/professors/professor.service.ts`
- `src/controllers/professors/professor.controller.ts`
- `src/routes/professors/professor.routes.ts`

**Funcionalidades:**
- CRUD de profesores
- Asignar profesores a inscripciones/materias
- Información de contacto (email, teléfono, oficina)
- Horarios de atención (office hours)
- Listado de materias que imparte
- Búsqueda y filtros

---

#### 2. Preferences Module
**Prioridad:** 🟢 MEDIA

**Archivos a crear:**
- `src/controllers/preferences/preference.controller.ts`
- `src/routes/preferences/preference.routes.ts`

**Funcionalidades:**
- Actualizar preferencias de usuario (basado en UserPreference existente)
- Configurar escala de calificación preferida
- Configurar notificaciones (email, push, alertas)
- Configurar tema (dark mode, compact view)
- Configurar idioma y timezone
- Configurar inicio de semana (lunes/domingo)

---

#### 3. Menu System
**Prioridad:** 🟢 BAJA

**Archivos a crear:**
- `src/types/schemas/menus/menu.schemas.ts`
- `src/services/menus/menu.service.ts`
- `src/controllers/menus/menu.controller.ts`
- `src/routes/menus/menu.routes.ts`

**Funcionalidades:**
- Obtener menú dinámico según plan del usuario
- Construir menús jerárquicos (menús con submenús)
- Validar acceso por plan (premium features)
- CRUD de menús (admin)
- Ordenamiento y badges
- Soporte para URLs externas

---

### ⚪ TIER 4 - BAJA PRIORIDAD (Refinamiento)

#### 4. Activity Logs
**Prioridad:** ⚪ MUY BAJA

**Funcionalidades:**
- Middleware automático para logging de acciones
- Consultar logs de actividad del usuario
- Filtros por usuario, acción, fecha, tipo
- Registro de cambios en datos importantes
- Auditoría de accesos

---

#### 5. Email Verification
**Prioridad:** ⚪ MUY BAJA

**Funcionalidades:**
- Completar flujo de verificación de email
- Envío de emails con templates HTML
- Reenviar token de verificación
- Manejo de expiración de tokens
- Integración con servicio de email (SendGrid, SES, etc.)

---

#### 6. Advanced Academic Features
**Prioridad:** ⚪ MUY BAJA

**Funcionalidades:**
- Estadísticas avanzadas por período académico
- Gráficas de progreso académico
- Predicción de GPA
- Sugerencias de materias a tomar
- Análisis de rendimiento por tipo de materia

---

## 🎯 Milestones del Proyecto

### ✅ Milestone 1: MVP Básico (COMPLETADO)
- [x] Autenticación completa (JWT + OAuth)
- [x] Users Routes (CRUD)
- [x] Careers Module
- [x] Subjects & Enrollment
- [x] Grades Module

**Estado:** ✅ COMPLETADO
**Objetivo:** Sistema funcional para gestionar carreras, materias y notas.

---

### ✅ Milestone 2: Funcionalidad Completa (COMPLETADO)
- [x] Schedules Module
- [x] Notifications Module
- [x] Subscriptions & Payments

**Estado:** ✅ COMPLETADO
**Objetivo:** Sistema completo con todas las features principales.

---

### 🔄 Milestone 3: Refinamiento (EN ESPERA)
- [ ] Professors Module
- [ ] Preferences Module
- [ ] Menu System

**Estado:** 🔄 PENDIENTE
**Objetivo:** Pulir detalles y agregar features secundarias.

---

### 🔄 Milestone 4: Optimización (FUTURO)
- [ ] Activity Logs
- [ ] Email Verification
- [ ] Advanced Academic Features

**Estado:** 🔄 FUTURO
**Objetivo:** Funcionalidades avanzadas y optimizaciones.

---

## 🏗️ Arquitectura y Patrones

### Estructura de Carpetas
```
src/
├── types/schemas/        # Esquemas de validación Zod
├── services/            # Lógica de negocio
├── controllers/         # Controladores HTTP
├── routes/             # Definición de rutas
├── middleware/         # Middlewares (auth, rate limit, etc.)
├── utils/              # Utilidades (apiResponse, etc.)
└── lib/                # Librerías (prisma, etc.)
```

### Patrón de Implementación Establecido

**1. Schema (Validación)**
```typescript
// types/schemas/[module]/[module].schemas.ts
import { z } from "zod";

export const createXSchema = z.object({
  // Validación con Zod
});

export type CreateXInput = z.infer<typeof createXSchema>;
```

**2. Service (Lógica de Negocio)**
```typescript
// services/[module]/[module].service.ts
import database from "@/lib/prisma/prisma";

class XService {
  async create(data: CreateXInput) {
    // Lógica de negocio
    return await database.x.create({ data });
  }
}

export const xService = new XService();
```

**3. Controller (HTTP)**
```typescript
// controllers/[module]/[module].controller.ts
import { sendSuccess, sendError } from "@/utils/response/apiResponse";

export async function create(req: Request, res: Response) {
  try {
    const data = createXSchema.parse(req.body);
    const result = await xService.create(data);
    return sendSuccess({ res, data: result });
  } catch (error) {
    return sendError({ res, error: "SERVER_ERROR" });
  }
}
```

**4. Routes (Endpoints)**
```typescript
// routes/[module]/[module].routes.ts
import { Router } from "express";
import { requireAuth } from "@/middleware/auth/auth.middleware";

const router = Router();
router.post("/", requireAuth, xController.create);
export default router;
```

### Convenciones de Código

**Manejo de Errores:**
- Usar `sendSuccess`, `sendError`, `sendErrorValidation` de `apiResponse`
- Errores personalizados con mensajes claros
- Validación con Zod antes de procesar

**Base de Datos:**
- Importar como `database` (no `prisma`)
- Tipos desde `@prisma/client`
- Soft delete con campo `state` ("A" = activo, "I" = inactivo)
- Usar transacciones para operaciones múltiples

**Autenticación:**
- Proteger endpoints con `requireAuth` middleware
- Acceder a usuario desde `req.user?.id`
- Validar permisos según necesidad

**TypeScript:**
- Usar tipos inferidos de Zod (`z.infer<typeof schema>`)
- Evitar `any` excepto en JSON fields de Prisma
- Tipos estrictos en servicios y controllers

---

## 🔄 Próximos Pasos

1. **Siguiente:** Professors Module (TIER 3)
2. **Luego:** Preferences Module (TIER 3)
3. **Después:** Menu System (TIER 3)
4. **Finalmente:** Módulos TIER 4 según prioridad de negocio

---

## 📝 Notas Técnicas

### Escalas de Calificación Soportadas
- **FIVE:** 0-5 (Colombia, México)
- **TEN:** 0-10 (Argentina, España)
- **HUNDRED:** 0-100 (USA porcentaje)
- **FOUR_GPA:** 0-4 GPA (USA)
- **SEVEN:** 1-7 (Chile)

### Estados de Inscripción
- **ENROLLED:** Inscrito pero no iniciado
- **IN_PROGRESS:** En curso
- **PASSED:** Aprobado
- **FAILED:** Reprobado
- **WITHDRAWN:** Retirado
- **DROPPED:** Dado de baja

### Tipos de Horario
- **CLASS:** Clase regular
- **LAB:** Laboratorio
- **EXAM:** Examen
- **OFFICE_HOURS:** Horario de atención
- **STUDY_GROUP:** Grupo de estudio
- **OTHER:** Otro

### Categorías de Notificación
- **SYSTEM:** Sistema
- **ACADEMIC:** Académico
- **GRADE:** Calificaciones
- **SCHEDULE:** Horarios
- **PAYMENT:** Pagos
- **SUBSCRIPTION:** Suscripciones
- **REMINDER:** Recordatorios

---

**Documento vivo - Se actualiza con cada módulo completado**
**Próxima revisión:** Después de completar Professors Module
