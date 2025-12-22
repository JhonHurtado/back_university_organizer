// =====================================================
// routes/notifications/notification.routes.ts
// =====================================================
import { Router } from "express";
import * as notificationController from "../../controllers/notifications/notification.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// NOTIFICATION ROUTES
// =====================================================
// Crear notificación (uso interno o admin)
router.post("/", requireAuth, notificationController.createNotification);

// Obtener notificaciones del usuario
router.get("/", requireAuth, notificationController.getNotifications);

// Obtener contador de no leídas
router.get("/unread/count", requireAuth, notificationController.getUnreadCount);

// Marcar todas como leídas
router.put("/read-all", requireAuth, notificationController.markAllAsRead);

// Eliminar todas las leídas
router.delete("/read-all", requireAuth, notificationController.deleteAllRead);

// Obtener notificación por ID
router.get("/:id", requireAuth, notificationController.getNotificationById);

// Actualizar notificación
router.put("/:id", requireAuth, notificationController.updateNotification);

// Marcar como leída
router.put("/:id/read", requireAuth, notificationController.markAsRead);

// Eliminar notificación
router.delete("/:id", requireAuth, notificationController.deleteNotification);

export default router;
