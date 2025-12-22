// =====================================================
// controllers/notifications/notification.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { notificationService } from "@/services/notifications/notification.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as notificationSchemas from "@/types/schemas/notifications/notification.schemas";

// =====================================================
// NOTIFICATION CONTROLLERS
// =====================================================
export async function createNotification(req: Request, res: Response) {
  try {
    const data = notificationSchemas.createNotificationSchema.parse(req.body);
    const notification = await notificationService.create(data);
    return sendSuccess({ res, code: 201, message: "Notificación creada exitosamente", data: notification });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "USER_NOT_FOUND") return sendError({ res, code: 404, message: "Usuario no encontrado", error: error.message });
    return sendError({ res, code: 500, message: "Error al crear notificación", error: "SERVER_ERROR" });
  }
}

export async function getNotifications(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const filters = notificationSchemas.notificationQuerySchema.parse(req.query);
    const result = await notificationService.getByUser(userId, filters);
    return sendSuccess({ res, message: "Notificaciones obtenidas exitosamente", data: result });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendError({ res, code: 500, message: "Error al obtener notificaciones", error: "SERVER_ERROR" });
  }
}

export async function getNotificationById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    const notification = await notificationService.getById(id, userId);
    if (!notification) return sendError({ res, code: 404, message: "Notificación no encontrada", error: "NOT_FOUND" });
    return sendSuccess({ res, message: "Notificación obtenida exitosamente", data: notification });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al obtener notificación", error: "SERVER_ERROR" });
  }
}

export async function updateNotification(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    const data = notificationSchemas.updateNotificationSchema.parse(req.body);
    const notification = await notificationService.update(id, userId, data);
    return sendSuccess({ res, message: "Notificación actualizada exitosamente", data: notification });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Notificación no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al actualizar notificación", error: "SERVER_ERROR" });
  }
}

export async function markAsRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    const notification = await notificationService.markAsRead(id, userId);
    return sendSuccess({ res, message: "Notificación marcada como leída", data: notification });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Notificación no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al marcar como leída", error: "SERVER_ERROR" });
  }
}

export async function markAllAsRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const result = await notificationService.markAllAsRead(userId);
    return sendSuccess({ res, message: `${result.count} notificaciones marcadas como leídas`, data: result });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al marcar todas como leídas", error: "SERVER_ERROR" });
  }
}

export async function deleteNotification(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    await notificationService.delete(id, userId);
    return sendSuccess({ res, message: "Notificación eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendError({ res, code: 404, message: "Notificación no encontrada", error: error.message });
    return sendError({ res, code: 500, message: "Error al eliminar notificación", error: "SERVER_ERROR" });
  }
}

export async function deleteAllRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const result = await notificationService.deleteAllRead(userId);
    return sendSuccess({ res, message: `${result.count} notificaciones eliminadas`, data: result });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al eliminar notificaciones", error: "SERVER_ERROR" });
  }
}

export async function getUnreadCount(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const count = await notificationService.getUnreadCount(userId);
    return sendSuccess({ res, message: "Contador obtenido exitosamente", data: { count } });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al obtener contador", error: "SERVER_ERROR" });
  }
}
