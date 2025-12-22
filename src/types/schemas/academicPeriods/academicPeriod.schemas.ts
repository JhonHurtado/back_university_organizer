// =====================================================
// types/schemas/academicPeriods/academicPeriod.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// CREATE ACADEMIC PERIOD SCHEMA
// =====================================================
export const createAcademicPeriodSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),

  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres"),

  year: z
    .number()
    .int("El año debe ser un entero")
    .min(2000, "El año debe ser mayor a 2000")
    .max(2100, "El año no puede exceder 2100"),

  period: z
    .number()
    .int("El período debe ser un entero")
    .positive("El período debe ser mayor a 0")
    .max(3, "El período no puede exceder 3"),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val)),

  endDate: z
    .string()
    .datetime("Fecha de finalización inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val)),

  isCurrent: z.boolean().default(false),
});

// =====================================================
// UPDATE ACADEMIC PERIOD SCHEMA
// =====================================================
export const updateAcademicPeriodSchema = z.object({
  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres")
    .optional(),

  year: z
    .number()
    .int("El año debe ser un entero")
    .min(2000, "El año debe ser mayor a 2000")
    .max(2100, "El año no puede exceder 2100")
    .optional(),

  period: z
    .number()
    .int("El período debe ser un entero")
    .positive("El período debe ser mayor a 0")
    .max(3, "El período no puede exceder 3")
    .optional(),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),

  endDate: z
    .string()
    .datetime("Fecha de finalización inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),

  isCurrent: z.boolean().optional(),
});

// =====================================================
// ACADEMIC PERIOD ID SCHEMA
// =====================================================
export const academicPeriodIdSchema = z.object({
  id: z.string().uuid("ID de período académico inválido"),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateAcademicPeriodInput = z.infer<typeof createAcademicPeriodSchema>;
export type UpdateAcademicPeriodInput = z.infer<typeof updateAcademicPeriodSchema>;
export type AcademicPeriodIdInput = z.infer<typeof academicPeriodIdSchema>;
