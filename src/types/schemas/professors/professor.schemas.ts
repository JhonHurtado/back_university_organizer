// =====================================================
// types/schemas/professors/professor.schemas.ts
// =====================================================

import { z } from "zod";

// =====================================================
// CREATE PROFESSOR SCHEMA
// =====================================================
export const createProfessorSchema = z.object({
  firstName: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres"),
  lastName: z
    .string()
    .min(2, "El apellido debe tener al menos 2 caracteres")
    .max(100, "El apellido no puede exceder 100 caracteres"),
  email: z.string().email("Email inválido").optional(),
  phone: z.string().max(20, "El teléfono no puede exceder 20 caracteres").optional(),
  office: z.string().max(100, "La oficina no puede exceder 100 caracteres").optional(),
  department: z.string().max(100, "El departamento no puede exceder 100 caracteres").optional(),
  title: z.string().max(100, "El título no puede exceder 100 caracteres").optional(),
  notes: z.string().optional(),
});

// =====================================================
// UPDATE PROFESSOR SCHEMA
// =====================================================
export const updateProfessorSchema = z.object({
  firstName: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres")
    .optional(),
  lastName: z
    .string()
    .min(2, "El apellido debe tener al menos 2 caracteres")
    .max(100, "El apellido no puede exceder 100 caracteres")
    .optional(),
  email: z.string().email("Email inválido").optional(),
  phone: z.string().max(20, "El teléfono no puede exceder 20 caracteres").optional(),
  office: z.string().max(100, "La oficina no puede exceder 100 caracteres").optional(),
  department: z.string().max(100, "El departamento no puede exceder 100 caracteres").optional(),
  title: z.string().max(100, "El título no puede exceder 100 caracteres").optional(),
  notes: z.string().optional(),
});

// =====================================================
// PROFESSOR ID SCHEMA
// =====================================================
export const professorIdSchema = z.object({
  id: z.string().uuid("ID de profesor inválido"),
});

// =====================================================
// SEARCH PROFESSORS SCHEMA
// =====================================================
export const searchProfessorsSchema = z.object({
  search: z.string().optional(),
  department: z.string().optional(),
  page: z.number().int().min(1).optional(),
  limit: z.number().int().min(1).max(100).optional(),
});

// =====================================================
// ASSIGN PROFESSOR TO ENROLLMENT SCHEMA
// =====================================================
export const assignProfessorSchema = z.object({
  enrollmentId: z.string().uuid("ID de inscripción inválido"),
  professorId: z.string().uuid("ID de profesor inválido"),
  role: z.string().max(50, "El rol no puede exceder 50 caracteres").default("main"),
});

// =====================================================
// REMOVE PROFESSOR FROM ENROLLMENT SCHEMA
// =====================================================
export const removeProfessorSchema = z.object({
  enrollmentId: z.string().uuid("ID de inscripción inválido"),
  professorId: z.string().uuid("ID de profesor inválido"),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateProfessorInput = z.infer<typeof createProfessorSchema>;
export type UpdateProfessorInput = z.infer<typeof updateProfessorSchema>;
export type ProfessorIdInput = z.infer<typeof professorIdSchema>;
export type SearchProfessorsInput = z.infer<typeof searchProfessorsSchema>;
export type AssignProfessorInput = z.infer<typeof assignProfessorSchema>;
export type RemoveProfessorInput = z.infer<typeof removeProfessorSchema>;
