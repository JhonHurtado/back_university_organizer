// =====================================================
// types/schemas/subjects/subject.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const SubjectTypeSchema = z.enum([
  "REQUIRED",
  "ELECTIVE",
  "FREE_ELECTIVE",
  "COMPLEMENTARY",
]);

// =====================================================
// CREATE SUBJECT SCHEMA
// =====================================================
export const createSubjectSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  semesterId: z.string().uuid("ID de semestre inválido"),

  code: z
    .string()
    .min(1, "El código es requerido")
    .max(50, "El código no puede exceder 50 caracteres"),

  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(200, "El nombre no puede exceder 200 caracteres"),

  description: z
    .string()
    .max(1000, "La descripción no puede exceder 1000 caracteres")
    .optional()
    .nullable(),

  credits: z
    .number()
    .int("Los créditos deben ser un entero")
    .positive("Los créditos deben ser mayor a 0")
    .max(20, "Los créditos no pueden exceder 20"),

  hoursPerWeek: z
    .number()
    .int("Las horas por semana deben ser un entero")
    .positive("Las horas por semana deben ser mayor a 0")
    .max(168, "Las horas por semana no pueden exceder 168")
    .optional()
    .nullable(),

  subjectType: SubjectTypeSchema.default("REQUIRED"),

  area: z.string().max(100, "El área no puede exceder 100 caracteres").optional().nullable(),

  gradeWeights: z.record(z.string(), z.number()).optional().nullable(),

  totalCuts: z
    .number()
    .int("El total de cortes debe ser un entero")
    .positive("El total de cortes debe ser mayor a 0")
    .max(10, "El total de cortes no puede exceder 10")
    .default(3),

  isElective: z.boolean().default(false),
});

// =====================================================
// UPDATE SUBJECT SCHEMA
// =====================================================
export const updateSubjectSchema = z.object({
  code: z.string().min(1, "El código es requerido").max(50, "El código no puede exceder 50 caracteres").optional(),

  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(200, "El nombre no puede exceder 200 caracteres")
    .optional(),

  description: z
    .string()
    .max(1000, "La descripción no puede exceder 1000 caracteres")
    .optional()
    .nullable(),

  credits: z
    .number()
    .int("Los créditos deben ser un entero")
    .positive("Los créditos deben ser mayor a 0")
    .max(20, "Los créditos no pueden exceder 20")
    .optional(),

  hoursPerWeek: z
    .number()
    .int("Las horas por semana deben ser un entero")
    .positive("Las horas por semana deben ser mayor a 0")
    .max(168, "Las horas por semana no pueden exceder 168")
    .optional()
    .nullable(),

  subjectType: SubjectTypeSchema.optional(),

  area: z.string().max(100, "El área no puede exceder 100 caracteres").optional().nullable(),

  gradeWeights: z.record(z.string(), z.number()).optional().nullable(),

  totalCuts: z
    .number()
    .int("El total de cortes debe ser un entero")
    .positive("El total de cortes debe ser mayor a 0")
    .max(10, "El total de cortes no puede exceder 10")
    .optional(),

  isElective: z.boolean().optional(),
});

// =====================================================
// PREREQUISITE/COREQUISITE SCHEMA
// =====================================================
export const addPrerequisiteSchema = z.object({
  prerequisiteId: z.string().uuid("ID de prerequisito inválido"),
  isStrict: z.boolean().default(true),
});

export const addCorequisiteSchema = z.object({
  corequisiteId: z.string().uuid("ID de corequisito inválido"),
});

// =====================================================
// SUBJECT ID SCHEMA
// =====================================================
export const subjectIdSchema = z.object({
  id: z.string().uuid("ID de materia inválido"),
});

// =====================================================
// QUERY PARAMS SCHEMA
// =====================================================
export const subjectQuerySchema = z.object({
  semesterId: z.string().uuid("ID de semestre inválido").optional(),
  subjectType: SubjectTypeSchema.optional(),
  isElective: z.coerce.boolean().optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateSubjectInput = z.infer<typeof createSubjectSchema>;
export type UpdateSubjectInput = z.infer<typeof updateSubjectSchema>;
export type AddPrerequisiteInput = z.infer<typeof addPrerequisiteSchema>;
export type AddCorequisiteInput = z.infer<typeof addCorequisiteSchema>;
export type SubjectIdInput = z.infer<typeof subjectIdSchema>;
export type SubjectQueryInput = z.infer<typeof subjectQuerySchema>;
export type SubjectType = z.infer<typeof SubjectTypeSchema>;
