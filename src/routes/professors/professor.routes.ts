// =====================================================
// routes/professors/professor.routes.ts
// =====================================================
import { Router } from "express";
import * as professorController from "../../controllers/professors/professor.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// =====================================================

// Buscar profesores
router.get("/search", requireAuth, professorController.search);

// Listar todos los profesores (con paginación y filtros)
router.get("/", requireAuth, professorController.getAll);

// Crear profesor
router.post("/", requireAuth, professorController.create);

// Asignar profesor a inscripción
router.post("/assign", requireAuth, professorController.assignToEnrollment);

// Remover profesor de inscripción
router.post("/remove", requireAuth, professorController.removeFromEnrollment);

// Obtener profesor por ID
router.get("/:id", requireAuth, professorController.getById);

// Obtener materias del profesor
router.get("/:id/subjects", requireAuth, professorController.getProfessorSubjects);

// Actualizar profesor
router.put("/:id", requireAuth, professorController.update);

// Eliminar profesor (soft delete)
router.delete("/:id", requireAuth, professorController.softDelete);

// Restaurar profesor eliminado
router.post("/:id/restore", requireAuth, professorController.restore);

export default router;
