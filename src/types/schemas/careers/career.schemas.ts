// =====================================================
// types/schemas/careers/career.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const GradeScaleSchema = z.enum([
  "FIVE",
  "TEN",
  "HUNDRED",
  "FOUR_GPA",
  "SEVEN",
]);

export const CareerStatusSchema = z.enum([
  "ACTIVE",
  "COMPLETED",
  "PAUSED",
  "CANCELLED",
  "GRADUATED",
]);

// =====================================================
// CREATE CAREER SCHEMA
// =====================================================
export const createCareerSchema = z.object({
  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(200, "El nombre no puede exceder 200 caracteres"),

  code: z
    .string()
    .max(50, "El código no puede exceder 50 caracteres")
    .optional()
    .nullable(),

  university: z
    .string()
    .min(2, "El nombre de la universidad debe tener al menos 2 caracteres")
    .max(200, "El nombre de la universidad no puede exceder 200 caracteres"),

  faculty: z
    .string()
    .max(200, "El nombre de la facultad no puede exceder 200 caracteres")
    .optional()
    .nullable(),

  campus: z
    .string()
    .max(200, "El nombre del campus no puede exceder 200 caracteres")
    .optional()
    .nullable(),

  totalCredits: z
    .number()
    .int("El total de créditos debe ser un número entero")
    .positive("El total de créditos debe ser mayor a 0"),

  totalSemesters: z
    .number()
    .int("El total de semestres debe ser un número entero")
    .positive("El total de semestres debe ser mayor a 0")
    .max(20, "El total de semestres no puede exceder 20"),

  currentSemester: z
    .number()
    .int("El semestre actual debe ser un número entero")
    .positive("El semestre actual debe ser mayor a 0")
    .default(1),

  gradeScale: GradeScaleSchema.default("FIVE"),

  minPassingGrade: z
    .number()
    .positive("La nota mínima de aprobación debe ser mayor a 0")
    .default(3.0),

  maxGrade: z
    .number()
    .positive("La nota máxima debe ser mayor a 0")
    .default(5.0),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val)),

  expectedEndDate: z
    .string()
    .datetime("Fecha de finalización esperada inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  color: z
    .string()
    .regex(/^#[0-9A-F]{6}$/i, "Color debe ser un código hexadecimal válido")
    .default("#3B82F6")
    .optional(),

  status: CareerStatusSchema.default("ACTIVE").optional(),
});

// =====================================================
// UPDATE CAREER SCHEMA
// =====================================================
export const updateCareerSchema = z.object({
  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(200, "El nombre no puede exceder 200 caracteres")
    .optional(),

  code: z
    .string()
    .max(50, "El código no puede exceder 50 caracteres")
    .optional()
    .nullable(),

  university: z
    .string()
    .min(2, "El nombre de la universidad debe tener al menos 2 caracteres")
    .max(200, "El nombre de la universidad no puede exceder 200 caracteres")
    .optional(),

  faculty: z
    .string()
    .max(200, "El nombre de la facultad no puede exceder 200 caracteres")
    .optional()
    .nullable(),

  campus: z
    .string()
    .max(200, "El nombre del campus no puede exceder 200 caracteres")
    .optional()
    .nullable(),

  totalCredits: z
    .number()
    .int("El total de créditos debe ser un número entero")
    .positive("El total de créditos debe ser mayor a 0")
    .optional(),

  totalSemesters: z
    .number()
    .int("El total de semestres debe ser un número entero")
    .positive("El total de semestres debe ser mayor a 0")
    .max(20, "El total de semestres no puede exceder 20")
    .optional(),

  currentSemester: z
    .number()
    .int("El semestre actual debe ser un número entero")
    .positive("El semestre actual debe ser mayor a 0")
    .optional(),

  gradeScale: GradeScaleSchema.optional(),

  minPassingGrade: z
    .number()
    .positive("La nota mínima de aprobación debe ser mayor a 0")
    .optional(),

  maxGrade: z
    .number()
    .positive("La nota máxima debe ser mayor a 0")
    .optional(),

  startDate: z
    .string()
    .datetime("Fecha de inicio inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),

  expectedEndDate: z
    .string()
    .datetime("Fecha de finalización esperada inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  actualEndDate: z
    .string()
    .datetime("Fecha de finalización actual inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  color: z
    .string()
    .regex(/^#[0-9A-F]{6}$/i, "Color debe ser un código hexadecimal válido")
    .optional(),

  status: CareerStatusSchema.optional(),
});

// =====================================================
// UPDATE SEMESTER SCHEMA
// =====================================================
export const updateSemesterSchema = z.object({
  currentSemester: z
    .number()
    .int("El semestre actual debe ser un número entero")
    .positive("El semestre actual debe ser mayor a 0"),
});

// =====================================================
// CAREER ID SCHEMA
// =====================================================
export const careerIdSchema = z.object({
  id: z.string().uuid("ID de carrera inválido"),
});

// =====================================================
// QUERY PARAMS SCHEMA
// =====================================================
export const careerQuerySchema = z.object({
  status: CareerStatusSchema.optional(),
  page: z.coerce.number().int().positive().default(1).optional(),
  limit: z.coerce.number().int().positive().max(100).default(10).optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateCareerInput = z.infer<typeof createCareerSchema>;
export type UpdateCareerInput = z.infer<typeof updateCareerSchema>;
export type UpdateSemesterInput = z.infer<typeof updateSemesterSchema>;
export type CareerIdInput = z.infer<typeof careerIdSchema>;
export type CareerQueryInput = z.infer<typeof careerQuerySchema>;
export type GradeScale = z.infer<typeof GradeScaleSchema>;
export type CareerStatus = z.infer<typeof CareerStatusSchema>;
