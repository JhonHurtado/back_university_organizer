// =====================================================
// types/schemas/enrollments/enrollment.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const EnrollmentStatusSchema = z.enum([
  "ENROLLED",
  "IN_PROGRESS",
  "COMPLETED",
  "PASSED",
  "FAILED",
  "WITHDRAWN",
  "CANCELLED",
]);

// =====================================================
// CREATE ENROLLMENT SCHEMA
// =====================================================
export const createEnrollmentSchema = z.object({
  subjectId: z.string().uuid("ID de materia inválido"),
  academicPeriodId: z.string().uuid("ID de período académico inválido"),

  attempt: z
    .number()
    .int("El intento debe ser un entero")
    .positive("El intento debe ser mayor a 0")
    .max(5, "El intento no puede exceder 5")
    .default(1),

  section: z.string().max(50, "La sección no puede exceder 50 caracteres").optional().nullable(),

  classroom: z.string().max(100, "El aula no puede exceder 100 caracteres").optional().nullable(),

  notes: z.string().max(500, "Las notas no pueden exceder 500 caracteres").optional().nullable(),
});

// =====================================================
// UPDATE ENROLLMENT SCHEMA
// =====================================================
export const updateEnrollmentSchema = z.object({
  status: EnrollmentStatusSchema.optional(),

  section: z.string().max(50, "La sección no puede exceder 50 caracteres").optional().nullable(),

  classroom: z.string().max(100, "El aula no puede exceder 100 caracteres").optional().nullable(),

  finalGrade: z.number().min(0, "La nota final no puede ser negativa").optional().nullable(),

  letterGrade: z.string().max(5, "La nota letra no puede exceder 5 caracteres").optional().nullable(),

  gradePoints: z.number().min(0, "Los puntos no pueden ser negativos").optional().nullable(),

  isPassed: z.boolean().optional().nullable(),

  notes: z.string().max(500, "Las notas no pueden exceder 500 caracteres").optional().nullable(),

  withdrawnAt: z
    .string()
    .datetime("Fecha de retiro inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  completedAt: z
    .string()
    .datetime("Fecha de finalización inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),
});

// =====================================================
// UPDATE STATUS SCHEMA
// =====================================================
export const updateEnrollmentStatusSchema = z.object({
  status: EnrollmentStatusSchema,
});

// =====================================================
// ENROLLMENT ID SCHEMA
// =====================================================
export const enrollmentIdSchema = z.object({
  id: z.string().uuid("ID de inscripción inválido"),
});

// =====================================================
// QUERY PARAMS SCHEMA
// =====================================================
export const enrollmentQuerySchema = z.object({
  subjectId: z.string().uuid("ID de materia inválido").optional(),
  academicPeriodId: z.string().uuid("ID de período académico inválido").optional(),
  status: EnrollmentStatusSchema.optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateEnrollmentInput = z.infer<typeof createEnrollmentSchema>;
export type UpdateEnrollmentInput = z.infer<typeof updateEnrollmentSchema>;
export type UpdateEnrollmentStatusInput = z.infer<typeof updateEnrollmentStatusSchema>;
export type EnrollmentIdInput = z.infer<typeof enrollmentIdSchema>;
export type EnrollmentQueryInput = z.infer<typeof enrollmentQuerySchema>;
export type EnrollmentStatus = z.infer<typeof EnrollmentStatusSchema>;
