// =====================================================
// types/schemas/semesters/semester.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// CREATE SEMESTER SCHEMA
// =====================================================
export const createSemesterSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),

  number: z
    .number()
    .int("El número de semestre debe ser un entero")
    .positive("El número de semestre debe ser mayor a 0")
    .max(20, "El número de semestre no puede exceder 20"),

  name: z.string().max(100, "El nombre no puede exceder 100 caracteres").optional().nullable(),

  minCredits: z
    .number()
    .int("Los créditos mínimos deben ser un entero")
    .positive("Los créditos mínimos deben ser mayor a 0")
    .optional()
    .nullable(),

  maxCredits: z
    .number()
    .int("Los créditos máximos deben ser un entero")
    .positive("Los créditos máximos deben ser mayor a 0")
    .optional()
    .nullable(),
});

// =====================================================
// UPDATE SEMESTER SCHEMA
// =====================================================
export const updateSemesterSchema = z.object({
  number: z
    .number()
    .int("El número de semestre debe ser un entero")
    .positive("El número de semestre debe ser mayor a 0")
    .max(20, "El número de semestre no puede exceder 20")
    .optional(),

  name: z.string().max(100, "El nombre no puede exceder 100 caracteres").optional().nullable(),

  minCredits: z
    .number()
    .int("Los créditos mínimos deben ser un entero")
    .positive("Los créditos mínimos deben ser mayor a 0")
    .optional()
    .nullable(),

  maxCredits: z
    .number()
    .int("Los créditos máximos deben ser un entero")
    .positive("Los créditos máximos deben ser mayor a 0")
    .optional()
    .nullable(),
});

// =====================================================
// SEMESTER ID SCHEMA
// =====================================================
export const semesterIdSchema = z.object({
  id: z.string().uuid("ID de semestre inválido"),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateSemesterInput = z.infer<typeof createSemesterSchema>;
export type UpdateSemesterInput = z.infer<typeof updateSemesterSchema>;
export type SemesterIdInput = z.infer<typeof semesterIdSchema>;
