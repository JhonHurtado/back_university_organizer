// =====================================================
// controllers/activityLogs/activityLog.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { activityLogService } from "@/services/activityLogs/activityLog.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as activityLogSchemas from "@/types/schemas/activityLogs/activityLog.schemas";

// =====================================================
// ACTIVITY LOG CONTROLLERS
// =====================================================

/**
 * Crear un log de actividad manualmente
 * Normalmente los logs se crean automáticamente via middleware
 */
export async function createActivityLog(req: Request, res: Response) {
  try {
    const data = activityLogSchemas.createActivityLogSchema.parse(req.body);

    // Extraer IP y User Agent del request
    const ipAddress = (req.headers["x-forwarded-for"] as string) || req.socket.remoteAddress || undefined;
    const userAgent = req.headers["user-agent"] || undefined;

    const log = await activityLogService.create({
      ...data,
      ipAddress: data.ipAddress || ipAddress,
      userAgent: data.userAgent || userAgent,
    });

    return sendSuccess({
      res,
      code: 201,
      message: "Log de actividad creado exitosamente",
      data: log,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al crear log de actividad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener logs de actividad del usuario autenticado
 */
export async function getActivityLogs(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const filters = activityLogSchemas.activityLogQuerySchema.parse(req.query);
    const result = await activityLogService.getByUser(userId, filters);

    return sendSuccess({
      res,
      message: "Logs de actividad obtenidos exitosamente",
      data: result,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al obtener logs de actividad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener todos los logs de actividad (ADMIN)
 */
export async function getAllActivityLogs(req: Request, res: Response) {
  try {
    const filters = activityLogSchemas.activityLogQuerySchema.parse(req.query);
    const result = await activityLogService.getAll(filters);

    return sendSuccess({
      res,
      message: "Todos los logs de actividad obtenidos exitosamente",
      data: result,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al obtener logs de actividad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener un log de actividad por ID
 */
export async function getActivityLogById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = activityLogSchemas.activityLogIdSchema.parse(req.params);
    const log = await activityLogService.getById(id, userId);

    if (!log) {
      return sendError({
        res,
        code: 404,
        message: "Log de actividad no encontrado",
        error: "NOT_FOUND",
      });
    }

    return sendSuccess({
      res,
      message: "Log de actividad obtenido exitosamente",
      data: log,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener log de actividad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener actividad por entidad
 */
export async function getActivityByEntity(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { entity, entityId } = req.params;

    if (!entity || !entityId) {
      return sendError({
        res,
        code: 400,
        message: "Entity y entityId son requeridos",
        error: "VALIDATION_ERROR",
      });
    }

    const logs = await activityLogService.getByEntity(entity, entityId, userId);

    return sendSuccess({
      res,
      message: "Actividad de la entidad obtenida exitosamente",
      data: logs,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener actividad de la entidad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener estadísticas de actividad del usuario
 */
export async function getUserStats(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const stats = await activityLogService.getUserStats(userId);

    return sendSuccess({
      res,
      message: "Estadísticas de actividad obtenidas exitosamente",
      data: stats,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener estadísticas de actividad",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Eliminar logs antiguos (ADMIN)
 */
export async function deleteOldLogs(req: Request, res: Response) {
  try {
    const { days } = req.query;
    const daysOld = days ? parseInt(days as string) : 90;

    if (isNaN(daysOld) || daysOld < 1) {
      return sendError({
        res,
        code: 400,
        message: "El parámetro 'days' debe ser un número positivo",
        error: "VALIDATION_ERROR",
      });
    }

    const result = await activityLogService.deleteOldLogs(daysOld);

    return sendSuccess({
      res,
      message: `${result.count} logs antiguos eliminados exitosamente`,
      data: result,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al eliminar logs antiguos",
      error: "SERVER_ERROR",
    });
  }
}
