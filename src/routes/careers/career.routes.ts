// =====================================================
// careers/career.routes.ts
// =====================================================
import { Router } from "express";
import * as careerController from "../../controllers/careers/career.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// =====================================================

// Crear carrera
router.post("/", requireAuth, careerController.create);

// Listar carreras del usuario
router.get("/", requireAuth, careerController.getAll);

// Obtener carrera por ID
router.get("/:id", requireAuth, careerController.getById);

// Obtener estadísticas de la carrera
router.get("/:id/stats", requireAuth, careerController.getStats);

// Actualizar carrera
router.put("/:id", requireAuth, careerController.update);

// Actualizar semestre actual
router.put("/:id/semester", requireAuth, careerController.updateSemester);

// Eliminar carrera (soft delete)
router.delete("/:id", requireAuth, careerController.softDelete);

// Restaurar carrera eliminada
router.post("/:id/restore", requireAuth, careerController.restore);

export default router;
