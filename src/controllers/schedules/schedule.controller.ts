// =====================================================
// controllers/schedules/schedule.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { scheduleService } from "@/services/schedules/schedule.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
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
    return sendSuccess({ res, code: 201, message: "Horario creado exitosamente", data: schedule });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendError({ res, code: 404, message: "Inscripción no encontrada", error: error.message });
    if (error.message === "SCHEDULE_CONFLICT") return sendError({ res, code: 409, message: "Conflicto de horario detectado", error: error.message });
    if (error.message === "INVALID_DATE_RANGE") return sendError({ res, code: 400, message: "Rango de fechas inválido", error: error.message });
    return sendError({ res, code: 500, message: "Error al crear horario", error: "SERVER_ERROR" });
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
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Horario no encontrado", error: error.message });
    if (error.message === "SCHEDULE_CONFLICT") return sendError({ res, code: 409, message: "Conflicto de horario detectado", error: error.message });
    return sendError({ res, code: 500, message: "Error al actualizar horario", error: "SERVER_ERROR" });
  }
}

export async function deleteSchedule(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleIdSchema.parse(req.params);
    await scheduleService.deleteSchedule(userId, id);
    return sendSuccess({ res, message: "Horario eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Horario no encontrado", error: error.message });
    return sendError({ res, code: 500, message: "Error al eliminar horario", error: "SERVER_ERROR" });
  }
}

export async function getSchedulesByEnrollment(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { enrollmentId } = req.params;
    const schedules = await scheduleService.getSchedulesByEnrollment(userId, enrollmentId);
    return sendSuccess({ res, message: "Horarios obtenidos exitosamente", data: schedules });
  } catch (error: any) {
    if (error.message === "ENROLLMENT_NOT_FOUND") return sendError({ res, code: 404, message: "Inscripción no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al obtener horarios", error: "SERVER_ERROR" });
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
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "CAREER_NOT_FOUND") return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al obtener horario semanal", error: "SERVER_ERROR" });
  }
}

export async function checkConflicts(req: Request, res: Response) {
  try {
    const { careerId } = req.params;
    const conflicts = await scheduleService.checkConflicts(careerId);
    return sendSuccess({ res, message: "Conflictos verificados", data: { conflicts, hasConflicts: conflicts.length > 0 } });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al verificar conflictos", error: "SERVER_ERROR" });
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
    return sendSuccess({ res, code: 201, message: "Excepción creada exitosamente", data: exception });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SCHEDULE_NOT_FOUND") return sendError({ res, code: 404, message: "Horario no encontrado", error: error.message });
    if (error.message === "EXCEPTION_ALREADY_EXISTS") return sendError({ res, code: 409, message: "Ya existe una excepción para esta fecha", error: error.message });
    return sendError({ res, code: 500, message: "Error al crear excepción", error: "SERVER_ERROR" });
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
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Excepción no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al actualizar excepción", error: "SERVER_ERROR" });
  }
}

export async function deleteException(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = scheduleSchemas.scheduleExceptionIdSchema.parse(req.params);
    await scheduleService.deleteException(userId, id);
    return sendSuccess({ res, message: "Excepción eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Excepción no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al eliminar excepción", error: "SERVER_ERROR" });
  }
}
