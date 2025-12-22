// =====================================================
// types/schemas/notifications/notification.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const NotificationTypeSchema = z.enum([
  "INFO",
  "SUCCESS",
  "WARNING",
  "ERROR",
]);

export const NotificationCategorySchema = z.enum([
  "SYSTEM",
  "ACADEMIC",
  "GRADE",
  "SCHEDULE",
  "PAYMENT",
  "SUBSCRIPTION",
  "REMINDER",
]);

// =====================================================
// CREATE NOTIFICATION SCHEMA
// =====================================================
export const createNotificationSchema = z.object({
  userId: z.string().uuid("ID de usuario inválido"),

  title: z
    .string()
    .min(1, "El título es requerido")
    .max(200, "El título no puede exceder 200 caracteres"),

  message: z
    .string()
    .min(1, "El mensaje es requerido")
    .max(1000, "El mensaje no puede exceder 1000 caracteres"),

  type: NotificationTypeSchema.default("INFO"),

  category: NotificationCategorySchema.default("SYSTEM"),

  actionUrl: z
    .string()
    .url("URL inválida")
    .max(500, "La URL no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  actionLabel: z
    .string()
    .max(100, "La etiqueta no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  metadata: z.record(z.string(), z.any()).optional().nullable(),

  imageUrl: z
    .string()
    .url("URL de imagen inválida")
    .max(500, "La URL no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  expiresAt: z
    .string()
    .datetime("Fecha de expiración inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),
});

// =====================================================
// UPDATE NOTIFICATION SCHEMA
// =====================================================
export const updateNotificationSchema = z.object({
  title: z
    .string()
    .min(1, "El título es requerido")
    .max(200, "El título no puede exceder 200 caracteres")
    .optional(),

  message: z
    .string()
    .min(1, "El mensaje es requerido")
    .max(1000, "El mensaje no puede exceder 1000 caracteres")
    .optional(),

  type: NotificationTypeSchema.optional(),

  category: NotificationCategorySchema.optional(),

  isRead: z.boolean().optional(),

  actionUrl: z
    .string()
    .url("URL inválida")
    .max(500, "La URL no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  actionLabel: z
    .string()
    .max(100, "La etiqueta no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  metadata: z.record(z.string(), z.any()).optional().nullable(),

  imageUrl: z
    .string()
    .url("URL de imagen inválida")
    .max(500, "La URL no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  expiresAt: z
    .string()
    .datetime("Fecha de expiración inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),
});

// =====================================================
// MARK AS READ SCHEMA
// =====================================================
export const markAsReadSchema = z.object({
  isRead: z.boolean().default(true),
});

// =====================================================
// NOTIFICATION ID SCHEMA
// =====================================================
export const notificationIdSchema = z.object({
  id: z.string().uuid("ID de notificación inválido"),
});

// =====================================================
// QUERY PARAMS SCHEMA
// =====================================================
export const notificationQuerySchema = z.object({
  type: NotificationTypeSchema.optional(),
  category: NotificationCategorySchema.optional(),
  isRead: z.coerce.boolean().optional(),
  page: z.coerce.number().int().positive().default(1).optional(),
  limit: z.coerce.number().int().positive().max(100).default(20).optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateNotificationInput = z.infer<typeof createNotificationSchema>;
export type UpdateNotificationInput = z.infer<typeof updateNotificationSchema>;
export type MarkAsReadInput = z.infer<typeof markAsReadSchema>;
export type NotificationIdInput = z.infer<typeof notificationIdSchema>;
export type NotificationQueryInput = z.infer<typeof notificationQuerySchema>;
export type NotificationType = z.infer<typeof NotificationTypeSchema>;
export type NotificationCategory = z.infer<typeof NotificationCategorySchema>;
