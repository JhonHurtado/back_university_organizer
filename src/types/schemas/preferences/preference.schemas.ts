// =====================================================
// types/schemas/preferences/preference.schemas.ts
// =====================================================

import { z } from "zod";
import { GradeScale } from "@prisma/client";

// =====================================================
// UPDATE PREFERENCES SCHEMA
// =====================================================
export const updatePreferencesSchema = z.object({
  // Notificaciones
  emailNotifications: z.boolean().optional(),
  pushNotifications: z.boolean().optional(),
  gradeAlerts: z.boolean().optional(),
  scheduleReminders: z.boolean().optional(),
  reminderMinutesBefore: z
    .number()
    .int("Debe ser un número entero")
    .min(0, "Debe ser mayor o igual a 0")
    .max(1440, "No puede ser mayor a 1440 minutos (24 horas)")
    .optional(),

  // Visualización
  darkMode: z.boolean().optional(),
  compactView: z.boolean().optional(),
  weekStartsOn: z
    .number()
    .int("Debe ser un número entero")
    .min(0, "0 = Domingo, 1 = Lunes")
    .max(6, "Máximo 6 (Sábado)")
    .optional(),

  // Académico
  gradeScale: z.nativeEnum(GradeScale).optional(),
  showGPA: z.boolean().optional(),
});

// =====================================================
// UPDATE NOTIFICATION PREFERENCES SCHEMA
// =====================================================
export const updateNotificationPreferencesSchema = z.object({
  emailNotifications: z.boolean().optional(),
  pushNotifications: z.boolean().optional(),
  gradeAlerts: z.boolean().optional(),
  scheduleReminders: z.boolean().optional(),
  reminderMinutesBefore: z
    .number()
    .int("Debe ser un número entero")
    .min(0, "Debe ser mayor o igual a 0")
    .max(1440, "No puede ser mayor a 1440 minutos (24 horas)")
    .optional(),
});

// =====================================================
// UPDATE DISPLAY PREFERENCES SCHEMA
// =====================================================
export const updateDisplayPreferencesSchema = z.object({
  darkMode: z.boolean().optional(),
  compactView: z.boolean().optional(),
  weekStartsOn: z
    .number()
    .int("Debe ser un número entero")
    .min(0, "0 = Domingo, 1 = Lunes")
    .max(6, "Máximo 6 (Sábado)")
    .optional(),
});

// =====================================================
// UPDATE ACADEMIC PREFERENCES SCHEMA
// =====================================================
export const updateAcademicPreferencesSchema = z.object({
  gradeScale: z.nativeEnum(GradeScale).optional(),
  showGPA: z.boolean().optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type UpdatePreferencesInput = z.infer<typeof updatePreferencesSchema>;
export type UpdateNotificationPreferencesInput = z.infer<
  typeof updateNotificationPreferencesSchema
>;
export type UpdateDisplayPreferencesInput = z.infer<
  typeof updateDisplayPreferencesSchema
>;
export type UpdateAcademicPreferencesInput = z.infer<
  typeof updateAcademicPreferencesSchema
>;
