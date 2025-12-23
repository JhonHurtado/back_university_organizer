// =====================================================
// controllers/notifications/notification.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { notificationService } from "@/services/notifications/notification.service";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as notificationSchemas from "@/types/schemas/notifications/notification.schemas";

// =====================================================
// NOTIFICATION CONTROLLERS
// =====================================================
export async function createNotification(req: Request, res: Response) {
  try {
    const data = notificationSchemas.createNotificationSchema.parse(req.body);
    const notification = await notificationService.create(data);
    return sendCreated({ res, message: "Notificación creada exitosamente", data: notification });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "USER_NOT_FOUND") return sendNotFound({ res, message: "Usuario no encontrado" });
    return sendServerError({ res, message: "Error al crear notificación" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendServerError({ res, message: "Error al obtener notificaciones" });
  }
}

export async function getNotificationById(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    const notification = await notificationService.getById(id, userId);
    if (!notification) return sendNotFound({ res, message: "Notificación no encontrada" });
    return sendSuccess({ res, message: "Notificación obtenida exitosamente", data: notification });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener notificación" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Notificación no encontrada" });
    return sendServerError({ res, message: "Error al actualizar notificación" });
  }
}

export async function markAsRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    const notification = await notificationService.markAsRead(id, userId);
    return sendSuccess({ res, message: "Notificación marcada como leída", data: notification });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Notificación no encontrada" });
    return sendServerError({ res, message: "Error al marcar como leída" });
  }
}

export async function markAllAsRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const result = await notificationService.markAllAsRead(userId);
    return sendSuccess({ res, message: `${result.count} notificaciones marcadas como leídas`, data: result });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al marcar todas como leídas" });
  }
}

export async function deleteNotification(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = notificationSchemas.notificationIdSchema.parse(req.params);
    await notificationService.delete(id, userId);
    return sendSuccess({ res, message: "Notificación eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "NOT_FOUND") return sendNotFound({ res, message: "Notificación no encontrada" });
    return sendServerError({ res, message: "Error al eliminar notificación" });
  }
}

export async function deleteAllRead(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const result = await notificationService.deleteAllRead(userId);
    return sendSuccess({ res, message: `${result.count} notificaciones eliminadas`, data: result });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al eliminar notificaciones" });
  }
}

export async function getUnreadCount(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const count = await notificationService.getUnreadCount(userId);
    return sendSuccess({ res, message: "Contador obtenido exitosamente", data: { count } });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener contador" });
  }
}
