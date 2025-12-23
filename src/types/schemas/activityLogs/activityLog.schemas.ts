// =====================================================
// types/schemas/activityLogs/activityLog.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const ActivityActionSchema = z.enum([
  "CREATE",
  "UPDATE",
  "DELETE",
  "RESTORE",
  "LOGIN",
  "LOGOUT",
  "REGISTER",
  "PASSWORD_RESET",
  "EMAIL_VERIFY",
  "EXPORT",
  "IMPORT",
  "VIEW",
  "DOWNLOAD",
  "UPLOAD",
  "SHARE",
  "ARCHIVE",
  "UNARCHIVE",
  "ACTIVATE",
  "DEACTIVATE",
  "APPROVE",
  "REJECT",
  "SUBMIT",
  "CANCEL",
  "OTHER",
]);

export const ActivityEntitySchema = z.enum([
  "USER",
  "CAREER",
  "SEMESTER",
  "SUBJECT",
  "ENROLLMENT",
  "GRADE",
  "SCHEDULE",
  "NOTIFICATION",
  "SUBSCRIPTION",
  "PAYMENT",
  "INVOICE",
  "PLAN",
  "MENU",
  "PROFESSOR",
  "PREFERENCE",
  "SESSION",
  "API_CLIENT",
  "OTHER",
]);

// =====================================================
// CREATE ACTIVITY LOG SCHEMA
// =====================================================
export const createActivityLogSchema = z.object({
  userId: z.string().uuid("ID de usuario inválido").optional().nullable(),

  action: ActivityActionSchema,

  entity: ActivityEntitySchema,

  entityId: z.string().max(255, "ID de entidad muy largo").optional().nullable(),

  oldValues: z.record(z.string(), z.any()).optional().nullable(),

  newValues: z.record(z.string(), z.any()).optional().nullable(),

  ipAddress: z
    .string()
    .max(45, "Dirección IP inválida") // IPv6 max length
    .optional()
    .nullable(),

  userAgent: z.string().max(500, "User agent muy largo").optional().nullable(),
});

// =====================================================
// QUERY PARAMS SCHEMA
// =====================================================
export const activityLogQuerySchema = z.object({
  userId: z.string().uuid("ID de usuario inválido").optional(),

  action: ActivityActionSchema.optional(),

  entity: ActivityEntitySchema.optional(),

  entityId: z.string().max(255, "ID de entidad muy largo").optional(),

  dateFrom: z
    .string()
    .datetime("Fecha desde inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),

  dateTo: z
    .string()
    .datetime("Fecha hasta inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),

  page: z.coerce.number().int().positive().default(1).optional(),

  limit: z.coerce.number().int().positive().max(100).default(20).optional(),

  sortBy: z.enum(["createdAt", "action", "entity"]).default("createdAt").optional(),

  sortOrder: z.enum(["asc", "desc"]).default("desc").optional(),
});

// =====================================================
// ACTIVITY LOG ID SCHEMA
// =====================================================
export const activityLogIdSchema = z.object({
  id: z.string().uuid("ID de log inválido"),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateActivityLogInput = z.infer<typeof createActivityLogSchema>;
export type ActivityLogQueryInput = z.infer<typeof activityLogQuerySchema>;
export type ActivityLogIdInput = z.infer<typeof activityLogIdSchema>;
export type ActivityAction = z.infer<typeof ActivityActionSchema>;
export type ActivityEntity = z.infer<typeof ActivityEntitySchema>;
