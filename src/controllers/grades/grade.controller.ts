// =====================================================
// controllers/grades/grade.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { gradeService } from "@/services/grades/grade.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as gradeSchemas from "@/types/schemas/grades/grade.schemas";

// =====================================================
// GRADE CONTROLLERS
// =====================================================
export async function createGrade(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = gradeSchemas.createGradeSchema.parse(req.body);
    const grade = await gradeService.createGrade(userId, data);
    return sendSuccess({ res, code: 201, message: "Nota creada exitosamente", data: grade });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendError({ res, code: 404, message: "Inscripción no encontrada", error: error.message });
    if (error.message === "INVALID_CUT_NUMBER") return sendError({ res, code: 400, message: "Número de corte inválido", error: error.message });
    if (error.message === "GRADE_ALREADY_EXISTS") return sendError({ res, code: 409, message: "Ya existe una nota para este corte", error: error.message });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendError({ res, code: 400, message: "La nota excede el máximo permitido", error: error.message });
    return sendError({ res, code: 500, message: "Error al crear nota", error: "SERVER_ERROR" });
  }
}

export async function updateGrade(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeIdSchema.parse(req.params);
    const data = gradeSchemas.updateGradeSchema.parse(req.body);
    const grade = await gradeService.updateGrade(userId, id, data);
    return sendSuccess({ res, message: "Nota actualizada exitosamente", data: grade });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Nota no encontrada", error: error.message });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendError({ res, code: 400, message: "La nota excede el máximo permitido", error: error.message });
    return sendError({ res, code: 500, message: "Error al actualizar nota", error: "SERVER_ERROR" });
  }
}

export async function deleteGrade(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeIdSchema.parse(req.params);
    await gradeService.deleteGrade(userId, id);
    return sendSuccess({ res, message: "Nota eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Nota no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al eliminar nota", error: "SERVER_ERROR" });
  }
}

export async function getGradesByEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { enrollmentId } = req.params;
    const grades = await gradeService.getGradesByEnrollment(userId, enrollmentId);
    return sendSuccess({ res, message: "Notas obtenidas exitosamente", data: grades });
  } catch (error: any) {
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendError({ res, code: 404, message: "Inscripción no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al obtener notas", error: "SERVER_ERROR" });
  }
}

// =====================================================
// GRADE ITEM CONTROLLERS
// =====================================================
export async function createGradeItem(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = gradeSchemas.createGradeItemSchema.parse(req.body);
    const gradeItem = await gradeService.createGradeItem(userId, data);
    return sendSuccess({ res, code: 201, message: "Item de nota creado exitosamente", data: gradeItem });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "GRADE_NOT_FOUND") return sendError({ res, code: 404, message: "Nota no encontrada", error: error.message });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendError({ res, code: 400, message: "La nota excede el máximo permitido", error: error.message });
    return sendError({ res, code: 500, message: "Error al crear item", error: "SERVER_ERROR" });
  }
}

export async function updateGradeItem(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeItemIdSchema.parse(req.params);
    const data = gradeSchemas.updateGradeItemSchema.parse(req.body);
    const gradeItem = await gradeService.updateGradeItem(userId, id, data);
    return sendSuccess({ res, message: "Item actualizado exitosamente", data: gradeItem });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Item no encontrado", error: error.message });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendError({ res, code: 400, message: "La nota excede el máximo permitido", error: error.message });
    return sendError({ res, code: 500, message: "Error al actualizar item", error: "SERVER_ERROR" });
  }
}

export async function deleteGradeItem(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeItemIdSchema.parse(req.params);
    await gradeService.deleteGradeItem(userId, id);
    return sendSuccess({ res, message: "Item eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Item no encontrado", error: error.message });
    return sendError({ res, code: 500, message: "Error al eliminar item", error: "SERVER_ERROR" });
  }
}

// =====================================================
// GPA CONTROLLER
// =====================================================
export async function getCareerGPA(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const gpa = await gradeService.getCareerGPA(userId, careerId);
    return sendSuccess({ res, message: "GPA calculado exitosamente", data: gpa });
  } catch (error: any) {
    if (error.message === "CAREER_NOT_FOUND") return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al calcular GPA", error: "SERVER_ERROR" });
  }
}
