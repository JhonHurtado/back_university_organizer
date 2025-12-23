// =====================================================
// controllers/grades/grade.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { gradeService } from "@/services/grades/grade.service";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendConflict,
  sendBadRequest,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";
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
    return sendCreated({ res, message: "Nota creada exitosamente", data: grade });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendNotFound({ res, message: "Inscripción no encontrada" });
    if (error.message === "INVALID_CUT_NUMBER") return sendBadRequest({ res, message: "Número de corte inválido" });
    if (error.message === "GRADE_ALREADY_EXISTS") return sendConflict({ res, message: "Ya existe una nota para este corte" });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendBadRequest({ res, message: "La nota excede el máximo permitido" });
    return sendServerError({ res, message: "Error al crear nota" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Nota no encontrada" });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendBadRequest({ res, message: "La nota excede el máximo permitido" });
    return sendServerError({ res, message: "Error al actualizar nota" });
  }
}

export async function deleteGrade(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeIdSchema.parse(req.params);
    await gradeService.deleteGrade(userId, id);
    return sendSuccess({ res, message: "Nota eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Nota no encontrada" });
    return sendServerError({ res, message: "Error al eliminar nota" });
  }
}

export async function getGradesByEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { enrollmentId } = req.params;
    const grades = await gradeService.getGradesByEnrollment(userId, enrollmentId);
    return sendSuccess({ res, message: "Notas obtenidas exitosamente", data: grades });
  } catch (error: any) {
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendNotFound({ res, message: "Inscripción no encontrada" });
    return sendServerError({ res, message: "Error al obtener notas" });
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
    return sendCreated({ res, message: "Item de nota creado exitosamente", data: gradeItem });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "GRADE_NOT_FOUND") return sendNotFound({ res, message: "Nota no encontrada" });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendBadRequest({ res, message: "La nota excede el máximo permitido" });
    return sendServerError({ res, message: "Error al crear item" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Item no encontrado" });
    if (error.message === "GRADE_EXCEEDS_MAX") return sendBadRequest({ res, message: "La nota excede el máximo permitido" });
    return sendServerError({ res, message: "Error al actualizar item" });
  }
}

export async function deleteGradeItem(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = gradeSchemas.gradeItemIdSchema.parse(req.params);
    await gradeService.deleteGradeItem(userId, id);
    return sendSuccess({ res, message: "Item eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Item no encontrado" });
    return sendServerError({ res, message: "Error al eliminar item" });
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
    if (error.message === "CAREER_NOT_FOUND") return sendNotFound({ res, message: "Carrera no encontrada" });
    return sendServerError({ res, message: "Error al calcular GPA" });
  }
}
