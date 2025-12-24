# University Organizer - Roadmap de Desarrollo

Este documento describe las tareas de desarrollo para la aplicación móvil de University Organizer, organizadas por módulos y prioridad.

## Leyenda

- 🔴 Alta prioridad (funcionalidad básica)
- 🟡 Media prioridad (funcionalidad importante)
- 🟢 Baja prioridad (mejoras y características adicionales)

---

## Fase 1: Fundamentos y Autenticación 🔴

### 1.1 Configuración Inicial
- [x] Crear estructura de carpetas
- [x] Configurar constantes de la aplicación
- [x] Configurar tema y colores
- [x] Configurar localización (ES/EN)
- [ ] Configurar navegación con go_router
- [ ] Configurar manejo de estado con Provider

### 1.2 Modelos de Datos
- [ ] Crear modelo User
- [ ] Crear modelo Career
- [ ] Crear modelo Subject
- [ ] Crear modelo Grade
- [ ] Crear modelo Schedule
- [ ] Crear modelo Professor
- [ ] Crear modelo Notification
- [ ] Crear modelo Subscription
- [ ] Crear serialización JSON para todos los modelos

### 1.3 Servicios de API Base
- [ ] Crear servicio HTTP base con Dio
- [ ] Implementar interceptores (auth, logging, error handling)
- [ ] Crear servicio de almacenamiento local
- [ ] Crear servicio de almacenamiento seguro (tokens)

### 1.4 Autenticación
#### API Endpoints:
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/google`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`

#### Tareas:
- [ ] Crear servicio de autenticación
- [ ] Implementar registro de usuario
- [ ] Implementar inicio de sesión
- [ ] Implementar autenticación con Google
- [ ] Implementar refresh token automático
- [ ] Implementar logout
- [ ] Crear provider de autenticación

#### Pantallas:
- [ ] Splash screen con verificación de sesión
- [ ] Login screen
- [ ] Register screen
- [ ] Forgot password screen

---

## Fase 2: Gestión de Perfil y Preferencias 🔴

### 2.1 Perfil de Usuario
#### API Endpoints:
- `GET /users/profile`
- `PUT /users/profile`
- `PUT /users/avatar`

#### Tareas:
- [ ] Crear servicio de usuario
- [ ] Implementar obtención de perfil
- [ ] Implementar actualización de perfil
- [ ] Implementar cambio de avatar
- [ ] Crear provider de usuario

#### Pantallas:
- [ ] Profile screen
- [ ] Edit profile screen

### 2.2 Preferencias
#### API Endpoints:
- `GET /preferences`
- `PUT /preferences`

#### Tareas:
- [ ] Crear servicio de preferencias
- [ ] Implementar obtención de preferencias
- [ ] Implementar actualización de preferencias
- [ ] Crear provider de preferencias

#### Pantallas:
- [ ] Settings screen
- [ ] Preferences screen (notificaciones, tema, idioma, etc.)

---

## Fase 3: Gestión de Carreras 🔴

### 3.1 Carreras
#### API Endpoints:
- `GET /careers`
- `POST /careers`
- `GET /careers/:id`
- `PUT /careers/:id`
- `DELETE /careers/:id`
- `GET /careers/:id/statistics`

#### Tareas:
- [ ] Crear servicio de carreras
- [ ] Implementar CRUD de carreras
- [ ] Implementar estadísticas de carrera
- [ ] Crear provider de carreras

#### Pantallas:
- [ ] Careers list screen
- [ ] Career detail screen
- [ ] Add/Edit career screen
- [ ] Career statistics screen

---

## Fase 4: Gestión de Materias y Períodos Académicos 🔴

### 4.1 Períodos Académicos
#### API Endpoints:
- `GET /academic/periods`
- `POST /academic/periods`
- `PUT /academic/periods/:id`
- `DELETE /academic/periods/:id`

#### Tareas:
- [ ] Crear servicio de períodos académicos
- [ ] Implementar CRUD de períodos
- [ ] Crear provider de períodos

### 4.2 Materias
#### API Endpoints:
- `GET /academic/subjects`
- `POST /academic/subjects`
- `GET /academic/subjects/:id`
- `PUT /academic/subjects/:id`
- `DELETE /academic/subjects/:id`

#### Tareas:
- [ ] Crear servicio de materias
- [ ] Implementar CRUD de materias
- [ ] Implementar gestión de prerequisitos
- [ ] Crear provider de materias

#### Pantallas:
- [ ] Subjects list screen (por carrera/semestre)
- [ ] Subject detail screen
- [ ] Add/Edit subject screen
- [ ] Subject prerequisites screen

### 4.3 Inscripción de Materias
#### API Endpoints:
- `POST /academic/enrollments`
- `GET /academic/enrollments/:id`
- `PUT /academic/enrollments/:id`
- `DELETE /academic/enrollments/:id`

#### Tareas:
- [ ] Crear servicio de inscripciones
- [ ] Implementar inscripción a materias
- [ ] Implementar retiro de materias
- [ ] Crear provider de inscripciones

---

## Fase 5: Gestión de Calificaciones 🔴

### 5.1 Calificaciones
#### API Endpoints:
- `GET /grades`
- `POST /grades`
- `GET /grades/:id`
- `PUT /grades/:id`
- `DELETE /grades/:id`
- `GET /grades/subject/:subjectId`

#### Tareas:
- [ ] Crear servicio de calificaciones
- [ ] Implementar CRUD de calificaciones
- [ ] Implementar cálculo de promedios
- [ ] Implementar cálculo de nota final
- [ ] Implementar sistema de cortes
- [ ] Crear provider de calificaciones

#### Pantallas:
- [ ] Grades overview screen (por período)
- [ ] Subject grades screen (desglose por cortes)
- [ ] Add/Edit grade screen
- [ ] Grade calculator screen

---

## Fase 6: Gestión de Horarios 🟡

### 6.1 Horarios
#### API Endpoints:
- `GET /schedules`
- `POST /schedules`
- `GET /schedules/:id`
- `PUT /schedules/:id`
- `DELETE /schedules/:id`
- `GET /schedules/week/:date`

#### Tareas:
- [ ] Crear servicio de horarios
- [ ] Implementar CRUD de horarios
- [ ] Implementar vista semanal
- [ ] Implementar detección de conflictos de horario
- [ ] Crear provider de horarios

#### Pantallas:
- [ ] Schedule weekly view
- [ ] Schedule daily view
- [ ] Add/Edit schedule screen
- [ ] Schedule conflicts screen

### 6.2 Excepciones de Horario
#### API Endpoints:
- `POST /schedules/:id/exceptions`
- `DELETE /schedules/:id/exceptions/:exceptionId`

#### Tareas:
- [ ] Implementar excepciones de horario
- [ ] Implementar cancelaciones
- [ ] Implementar cambios de salón

---

## Fase 7: Gestión de Profesores 🟡

### 7.1 Profesores
#### API Endpoints:
- `GET /professors`
- `POST /professors`
- `GET /professors/:id`
- `PUT /professors/:id`
- `DELETE /professors/:id`

#### Tareas:
- [ ] Crear servicio de profesores
- [ ] Implementar CRUD de profesores
- [ ] Implementar asignación a materias
- [ ] Crear provider de profesores

#### Pantallas:
- [ ] Professors list screen
- [ ] Professor detail screen
- [ ] Add/Edit professor screen

---

## Fase 8: Notificaciones 🟡

### 8.1 Notificaciones
#### API Endpoints:
- `GET /notifications`
- `GET /notifications/unread-count`
- `PUT /notifications/:id/read`
- `PUT /notifications/mark-all-read`
- `DELETE /notifications/:id`

#### Tareas:
- [ ] Crear servicio de notificaciones
- [ ] Implementar listado de notificaciones
- [ ] Implementar marcar como leída
- [ ] Implementar notificaciones push (Firebase)
- [ ] Crear provider de notificaciones

#### Pantallas:
- [ ] Notifications list screen
- [ ] Notification detail screen

---

## Fase 9: Dashboard y Analíticas 🟡

### 9.1 Dashboard
#### Tareas:
- [ ] Crear dashboard principal
- [ ] Mostrar resumen de calificaciones
- [ ] Mostrar próximos eventos
- [ ] Mostrar horario del día
- [ ] Mostrar notificaciones recientes

#### Pantallas:
- [ ] Home/Dashboard screen

### 9.2 Analíticas
#### API Endpoints:
- `GET /analytics/grades`
- `GET /analytics/performance`
- `GET /analytics/attendance`

#### Tareas:
- [ ] Crear servicio de analíticas
- [ ] Implementar gráficos de calificaciones
- [ ] Implementar gráficos de rendimiento por materia
- [ ] Implementar comparativa de períodos
- [ ] Crear provider de analíticas

#### Pantallas:
- [ ] Analytics overview screen
- [ ] Grade analytics screen
- [ ] Performance analytics screen

---

## Fase 10: Suscripciones y Pagos 🟢

### 10.1 Planes y Suscripciones
#### API Endpoints:
- `GET /subscriptions/plans`
- `GET /subscriptions/current`
- `POST /subscriptions/subscribe`
- `PUT /subscriptions/cancel`
- `GET /subscriptions/features`

#### Tareas:
- [ ] Crear servicio de suscripciones
- [ ] Implementar listado de planes
- [ ] Implementar suscripción a plan
- [ ] Implementar cancelación de suscripción
- [ ] Verificar acceso a features premium
- [ ] Crear provider de suscripciones

#### Pantallas:
- [ ] Plans screen
- [ ] Current subscription screen
- [ ] Payment method screen

### 10.2 Pagos
#### API Endpoints:
- `GET /payments`
- `GET /payments/:id`

#### Tareas:
- [ ] Crear servicio de pagos
- [ ] Implementar historial de pagos
- [ ] Integrar pasarela de pago
- [ ] Crear provider de pagos

#### Pantallas:
- [ ] Payment history screen
- [ ] Payment detail screen

---

## Fase 11: Calendario y Eventos 🟢

### 11.1 Calendario
#### Tareas:
- [ ] Integrar table_calendar
- [ ] Mostrar eventos del calendario
- [ ] Sincronizar con horarios
- [ ] Sincronizar con fechas de exámenes
- [ ] Crear provider de calendario

#### Pantallas:
- [ ] Calendar screen
- [ ] Add event screen
- [ ] Event detail screen

---

## Fase 12: Características Adicionales 🟢

### 12.1 Exportación
#### Tareas:
- [ ] Implementar exportación de horario a PDF
- [ ] Implementar exportación de calificaciones a PDF/Excel
- [ ] Compartir horario por imagen

### 12.2 Recordatorios
#### Tareas:
- [ ] Implementar recordatorios de clases
- [ ] Implementar recordatorios de exámenes
- [ ] Implementar recordatorios de tareas
- [ ] Configurar tiempos de recordatorio

### 12.3 Menús Dinámicos
#### API Endpoints:
- `GET /menus`

#### Tareas:
- [ ] Implementar sistema de menús dinámicos
- [ ] Verificar permisos por plan
- [ ] Crear navegación dinámica

### 12.4 Logs de Actividad
#### API Endpoints:
- `GET /activity-logs`

#### Tareas:
- [ ] Implementar visualización de logs
- [ ] Filtros por tipo de actividad

---

## Fase 13: Testing y Optimización 🟡

### 13.1 Testing
- [ ] Tests unitarios para servicios
- [ ] Tests unitarios para providers
- [ ] Tests de integración
- [ ] Tests de widgets

### 13.2 Optimización
- [ ] Implementar caché de imágenes
- [ ] Implementar paginación en listas
- [ ] Optimizar rendimiento de gráficos
- [ ] Implementar lazy loading
- [ ] Reducir tamaño del APK

### 13.3 Offline Support
- [ ] Implementar sincronización offline
- [ ] Caché de datos críticos
- [ ] Manejo de conflictos de sincronización

---

## Fase 14: Pulido y Lanzamiento 🟢

### 14.1 UX/UI
- [ ] Revisar flujos de usuario
- [ ] Implementar animaciones
- [ ] Implementar estados de carga
- [ ] Implementar estados de error
- [ ] Implementar estados vacíos

### 14.2 Accesibilidad
- [ ] Soporte para lectores de pantalla
- [ ] Navegación por teclado
- [ ] Contraste de colores
- [ ] Tamaños de fuente ajustables

### 14.3 Documentación
- [ ] Documentar código
- [ ] Crear guías de usuario
- [ ] Crear guías de desarrollo

### 14.4 Preparación para Lanzamiento
- [ ] Configurar Firebase (Analytics, Crashlytics)
- [ ] Configurar deep links
- [ ] Preparar assets (iconos, splash screens)
- [ ] Configurar CI/CD
- [ ] Preparar para App Store
- [ ] Preparar para Google Play

---

## Resumen de Prioridades

### MVP (Mínimo Producto Viable)
Las siguientes funcionalidades son esenciales para el MVP:

1. Autenticación (login, registro)
2. Gestión de carreras (crear, editar, eliminar)
3. Gestión de materias (CRUD básico)
4. Gestión de calificaciones (CRUD básico, cálculo de promedios)
5. Visualización de horarios (vista semanal básica)
6. Perfil de usuario
7. Dashboard básico

### Post-MVP
- Sistema completo de notificaciones
- Analíticas avanzadas
- Gestión de profesores
- Sistema de suscripciones
- Exportación de datos
- Calendario de eventos
- Optimizaciones y mejoras de UX

---

## Notas de Desarrollo

### Prioridades Técnicas
1. Mantener el código limpio y bien documentado
2. Seguir los principios SOLID
3. Implementar manejo de errores robusto
4. Validar datos en cliente y servidor
5. Mantener seguridad de tokens y datos sensibles

### Consideraciones de Diseño
1. Seguir Material Design 3
2. Mantener consistencia visual
3. Optimizar para diferentes tamaños de pantalla
4. Soportar orientación portrait y landscape (donde aplique)

### Performance
1. Lazy loading de imágenes
2. Paginación en listas largas
3. Debouncing en búsquedas
4. Caché inteligente de datos

---

**Última actualización**: Diciembre 2024
