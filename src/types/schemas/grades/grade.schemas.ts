// =====================================================
// types/schemas/grades/grade.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const GradeItemTypeSchema = z.enum([
  "EXAM",
  "QUIZ",
  "ASSIGNMENT",
  "PROJECT",
  "LAB",
  "PRESENTATION",
  "PARTICIPATION",
  "OTHER",
]);

// =====================================================
// CREATE GRADE SCHEMA
// =====================================================
export const createGradeSchema = z.object({
  enrollmentId: z.string().uuid("ID de inscripción inválido"),

  cutNumber: z
    .number()
    .int("El número de corte debe ser un entero")
    .positive("El número de corte debe ser mayor a 0")
    .max(10, "El número de corte no puede exceder 10"),

  cutName: z
    .string()
    .max(100, "El nombre del corte no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  weight: z
    .number()
    .min(0, "El peso no puede ser negativo")
    .max(100, "El peso no puede exceder 100"),

  grade: z.number().min(0, "La nota no puede ser negativa"),

  maxGrade: z.number().positive("La nota máxima debe ser mayor a 0").default(5.0),

  description: z
    .string()
    .max(500, "La descripción no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  notes: z
    .string()
    .max(1000, "Las notas no pueden exceder 1000 caracteres")
    .optional()
    .nullable(),

  gradedAt: z
    .string()
    .datetime("Fecha de calificación inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),
});

// =====================================================
// UPDATE GRADE SCHEMA
// =====================================================
export const updateGradeSchema = z.object({
  cutName: z
    .string()
    .max(100, "El nombre del corte no puede exceder 100 caracteres")
    .optional()
    .nullable(),

  weight: z
    .number()
    .min(0, "El peso no puede ser negativo")
    .max(100, "El peso no puede exceder 100")
    .optional(),

  grade: z.number().min(0, "La nota no puede ser negativa").optional(),

  maxGrade: z.number().positive("La nota máxima debe ser mayor a 0").optional(),

  description: z
    .string()
    .max(500, "La descripción no puede exceder 500 caracteres")
    .optional()
    .nullable(),

  notes: z
    .string()
    .max(1000, "Las notas no pueden exceder 1000 caracteres")
    .optional()
    .nullable(),

  gradedAt: z
    .string()
    .datetime("Fecha de calificación inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional(),
});

// =====================================================
// CREATE GRADE ITEM SCHEMA
// =====================================================
export const createGradeItemSchema = z.object({
  gradeId: z.string().uuid("ID de nota inválido"),

  name: z
    .string()
    .min(1, "El nombre es requerido")
    .max(200, "El nombre no puede exceder 200 caracteres"),

  type: GradeItemTypeSchema,

  weight: z
    .number()
    .min(0, "El peso no puede ser negativo")
    .max(100, "El peso no puede exceder 100"),

  grade: z.number().min(0, "La nota no puede ser negativa"),

  maxGrade: z.number().positive("La nota máxima debe ser mayor a 0").default(5.0),

  dueDate: z
    .string()
    .datetime("Fecha de entrega inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  submittedAt: z
    .string()
    .datetime("Fecha de envío inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  notes: z
    .string()
    .max(1000, "Las notas no pueden exceder 1000 caracteres")
    .optional()
    .nullable(),
});

// =====================================================
// UPDATE GRADE ITEM SCHEMA
// =====================================================
export const updateGradeItemSchema = z.object({
  name: z
    .string()
    .min(1, "El nombre es requerido")
    .max(200, "El nombre no puede exceder 200 caracteres")
    .optional(),

  type: GradeItemTypeSchema.optional(),

  weight: z
    .number()
    .min(0, "El peso no puede ser negativo")
    .max(100, "El peso no puede exceder 100")
    .optional(),

  grade: z.number().min(0, "La nota no puede ser negativa").optional(),

  maxGrade: z.number().positive("La nota máxima debe ser mayor a 0").optional(),

  dueDate: z
    .string()
    .datetime("Fecha de entrega inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  submittedAt: z
    .string()
    .datetime("Fecha de envío inválida")
    .or(z.date())
    .transform((val) => (typeof val === "string" ? new Date(val) : val))
    .optional()
    .nullable(),

  notes: z
    .string()
    .max(1000, "Las notas no pueden exceder 1000 caracteres")
    .optional()
    .nullable(),
});

// =====================================================
// ID SCHEMAS
// =====================================================
export const gradeIdSchema = z.object({
  id: z.string().uuid("ID de nota inválido"),
});

export const gradeItemIdSchema = z.object({
  id: z.string().uuid("ID de item inválido"),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateGradeInput = z.infer<typeof createGradeSchema>;
export type UpdateGradeInput = z.infer<typeof updateGradeSchema>;
export type CreateGradeItemInput = z.infer<typeof createGradeItemSchema>;
export type UpdateGradeItemInput = z.infer<typeof updateGradeItemSchema>;
export type GradeIdInput = z.infer<typeof gradeIdSchema>;
export type GradeItemIdInput = z.infer<typeof gradeItemIdSchema>;
export type GradeItemType = z.infer<typeof GradeItemTypeSchema>;
