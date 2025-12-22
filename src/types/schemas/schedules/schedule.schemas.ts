// =====================================================
// types/schemas/schedules/schedule.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const ScheduleTypeSchema = z.enum([
  "CLASS",
  "LAB",
  "TUTORIAL",
  "OFFICE_HOURS",
  "EXAM",
  "OTHER",
]);

export const ExceptionTypeSchema = z.enum([
  "CANCELLED",
  "RESCHEDULED",
  "ROOM_CHANGE",
  "HOLIDAY",
]);

// =====================================================
// TIME VALIDATION HELPER
// =====================================================
const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;

// =====================================================
// CREATE SCHEDULE SCHEMA
// =====================================================
export const createScheduleSchema = z.object({
  enrollmentId: z.string().uuid("ID de inscripción inválido"),

  dayOfWeek: z
    .number()
    .int("El día de la semana debe ser un entero")
    .min(0, "El día debe ser entre 0 (Domingo) y 6 (Sábado)")
    .max(6, "El día debe ser entre 0 (Domingo) y 6 (Sábado)"),

  startTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)"),

  endTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)"),

  room: z
    .string()
    .max(100, "El salón no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  building: z
    .string()
    .max(100, "El edificio no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  type: ScheduleTypeSchema.default("CLASS"),

  color: z
    .string()
    .regex(/^#[0-9A-F]{6}$/i, "Color debe ser un código hexadecimal válido")
    .default("#3B82F6")
    .optional(),

  notes: z
    .string()
    .max(500, "Las notas no pueden exceder 500 caracteres")
    .optional()
    .nullable(),

  isRecurring: z.boolean().default(true),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  endDate: z
    .string()
    .datetime("Fecha de finalización inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),
}).refine(
  (data) => {
    const [startHour, startMin] = data.startTime.split(":").map(Number);
    const [endHour, endMin] = data.endTime.split(":").map(Number);
    const startMinutes = startHour * 60 + startMin;
    const endMinutes = endHour * 60 + endMin;
    return endMinutes > startMinutes;
  },
  {
    message: "La hora de finalización debe ser posterior a la hora de inicio",
    path: ["endTime"],
  }
);

// =====================================================
// UPDATE SCHEDULE SCHEMA
// =====================================================
export const updateScheduleSchema = z.object({
  dayOfWeek: z
    .number()
    .int("El día de la semana debe ser un entero")
    .min(0, "El día debe ser entre 0 (Domingo) y 6 (Sábado)")
    .max(6, "El día debe ser entre 0 (Domingo) y 6 (Sábado)")
    .optional(),

  startTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional(),

  endTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional(),

  room: z
    .string()
    .max(100, "El salón no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  building: z
    .string()
    .max(100, "El edificio no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  type: ScheduleTypeSchema.optional(),

  color: z
    .string()
    .regex(/^#[0-9A-F]{6}$/i, "Color debe ser un código hexadecimal válido")
    .optional(),

  notes: z
    .string()
    .max(500, "Las notas no pueden exceder 500 caracteres")
    .optional()
    .nullable(),

  isRecurring: z.boolean().optional(),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  endDate: z
    .string()
    .datetime("Fecha de finalización inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),
});

// =====================================================
// CREATE SCHEDULE EXCEPTION SCHEMA
// =====================================================
export const createScheduleExceptionSchema = z.object({
  scheduleId: z.string().uuid("ID de horario inválido"),

  date: z
    .string()
    .datetime("Fecha inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val)),

  type: ExceptionTypeSchema,

  newStartTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional()
    .nullable(),

  newEndTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional()
    .nullable(),

  newRoom: z
    .string()
    .max(100, "El salón no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  reason: z
    .string()
    .max(500, "La razón no puede exceder 500 caracteres")
    .optional()
    .nullable(),
});

// =====================================================
// UPDATE SCHEDULE EXCEPTION SCHEMA
// =====================================================
export const updateScheduleExceptionSchema = z.object({
  type: ExceptionTypeSchema.optional(),

  newStartTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional()
    .nullable(),

  newEndTime: z
    .string()
    .regex(timeRegex, "Formato de hora inválido (HH:MM)")
    .optional()
    .nullable(),

  newRoom: z
    .string()
    .max(100, "El salón no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  reason: z
    .string()
    .max(500, "La razón no puede exceder 500 caracteres")
    .optional()
    .nullable(),
});

// =====================================================
// ID SCHEMAS
// =====================================================
export const scheduleIdSchema = z.object({
  id: z.string().uuid("ID de horario inválido"),
});

export const scheduleExceptionIdSchema = z.object({
  id: z.string().uuid("ID de excepción inválido"),
});

// =====================================================
// QUERY SCHEMAS
// =====================================================
export const weeklyScheduleQuerySchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  date: z
    .string()
    .datetime("Fecha inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateScheduleInput = z.infer<typeof createScheduleSchema>;
export type UpdateScheduleInput = z.infer<typeof updateScheduleSchema>;
export type CreateScheduleExceptionInput = z.infer<typeof createScheduleExceptionSchema>;
export type UpdateScheduleExceptionInput = z.infer<typeof updateScheduleExceptionSchema>;
export type ScheduleIdInput = z.infer<typeof scheduleIdSchema>;
export type ScheduleExceptionIdInput = z.infer<typeof scheduleExceptionIdSchema>;
export type WeeklyScheduleQueryInput = z.infer<typeof weeklyScheduleQuerySchema>;
export type ScheduleType = z.infer<typeof ScheduleTypeSchema>;
export type ExceptionType = z.infer<typeof ExceptionTypeSchema>;
