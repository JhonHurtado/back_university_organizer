// =====================================================
// routes/activityLogs/activityLog.routes.ts
// =====================================================
import { Router } from "express";
import * as activityLogController from "../../controllers/activityLogs/activityLog.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// ACTIVITY LOG ROUTES
// =====================================================

// Obtener logs de actividad del usuario autenticado
router.get("/", requireAuth, activityLogController.getActivityLogs);

// Obtener estadísticas de actividad del usuario
router.get("/stats", requireAuth, activityLogController.getUserStats);

// Obtener todos los logs (admin - TODO: agregar middleware de admin)
router.get("/admin/all", requireAuth, activityLogController.getAllActivityLogs);

// Eliminar logs antiguos (admin - TODO: agregar middleware de admin)
router.delete("/admin/clean", requireAuth, activityLogController.deleteOldLogs);

// Obtener actividad por entidad
router.get("/entity/:entity/:entityId", requireAuth, activityLogController.getActivityByEntity);

// Obtener log por ID
router.get("/:id", requireAuth, activityLogController.getActivityLogById);

// Crear log manualmente (uso interno o admin)
router.post("/", requireAuth, activityLogController.createActivityLog);

export default router;
