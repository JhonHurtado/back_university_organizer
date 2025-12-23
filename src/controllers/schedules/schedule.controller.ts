// =====================================================
// controllers/schedules/schedule.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { scheduleService } from "@/services/schedules/schedule.service";
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
import * as scheduleSchemas from "@/types/schemas/schedules/schedule.schemas";

// =====================================================
// SCHEDULE CONTROLLERS
// =====================================================
export async function createSchedule(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = scheduleSchemas.createScheduleSchema.parse(req.body);
    const schedule = await scheduleService.createSchedule(userId, data);
    return sendCreated({ res, message: "Horario creado exitosamente", data: schedule });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendNotFound({ res, message: "Inscripción no encontrada" });
    if (error.message === "SCHEDULE_CONFLICT") return sendConflict({ res, message: "Conflicto de horario detectado" });
    if (error.message === "INVALID_DATE_RANGE") return sendBadRequest({ res, message: "Rango de fechas inválido" });
    return sendServerError({ res, message: "Error al crear horario" });
  }
}

export async function updateSchedule(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleIdSchema.parse(req.params);
    const data = scheduleSchemas.updateScheduleSchema.parse(req.body);
    const schedule = await scheduleService.updateSchedule(userId, id, data);
    return sendSuccess({ res, message: "Horario actualizado exitosamente", data: schedule });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Horario no encontrado" });
    if (error.message === "SCHEDULE_CONFLICT") return sendConflict({ res, message: "Conflicto de horario detectado" });
    return sendServerError({ res, message: "Error al actualizar horario" });
  }
}

export async function deleteSchedule(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleIdSchema.parse(req.params);
    await scheduleService.deleteSchedule(userId, id);
    return sendSuccess({ res, message: "Horario eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Horario no encontrado" });
    return sendServerError({ res, message: "Error al eliminar horario" });
  }
}

export async function getSchedulesByEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { enrollmentId } = req.params;
    const schedules = await scheduleService.getSchedulesByEnrollment(userId, enrollmentId);
    return sendSuccess({ res, message: "Horarios obtenidos exitosamente", data: schedules });
  } catch (error: any) {
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendNotFound({ res, message: "Inscripción no encontrada" });
    return sendServerError({ res, message: "Error al obtener horarios" });
  }
}

export async function getWeeklySchedule(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const query = scheduleSchemas.weeklyScheduleQuerySchema.parse(req.query);
    const weeklySchedule = await scheduleService.getWeeklySchedule(userId, query);
    return sendSuccess({ res, message: "Horario semanal obtenido exitosamente", data: weeklySchedule });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "CAREER_NOT_FOUND") return sendNotFound({ res, message: "Carrera no encontrada" });
    return sendServerError({ res, message: "Error al obtener horario semanal" });
  }
}

export async function checkConflicts(req: Request, res: Response) {
  try {
    const { careerId } = req.params;
    const conflicts = await scheduleService.checkConflicts(careerId);
    return sendSuccess({ res, message: "Conflictos verificados", data: { conflicts, hasConflicts: conflicts.length > 0 } });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al verificar conflictos" });
  }
}

// =====================================================
// SCHEDULE EXCEPTION CONTROLLERS
// =====================================================
export async function createException(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const data = scheduleSchemas.createScheduleExceptionSchema.parse(req.body);
    const exception = await scheduleService.createException(userId, data);
    return sendCreated({ res, message: "Excepción creada exitosamente", data: exception });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SCHEDULE_NOT_FOUND") return sendNotFound({ res, message: "Horario no encontrado" });
    if (error.message === "EXCEPTION_ALREADY_EXISTS") return sendConflict({ res, message: "Ya existe una excepción para esta fecha" });
    return sendServerError({ res, message: "Error al crear excepción" });
  }
}

export async function updateException(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleExceptionIdSchema.parse(req.params);
    const data = scheduleSchemas.updateScheduleExceptionSchema.parse(req.body);
    const exception = await scheduleService.updateException(userId, id, data);
    return sendSuccess({ res, message: "Excepción actualizada exitosamente", data: exception });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Excepción no encontrada" });
    return sendServerError({ res, message: "Error al actualizar excepción" });
  }
}

export async function deleteException(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleExceptionIdSchema.parse(req.params);
    await scheduleService.deleteException(userId, id);
    return sendSuccess({ res, message: "Excepción eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Excepción no encontrada" });
    return sendServerError({ res, message: "Error al eliminar excepción" });
  }
}
