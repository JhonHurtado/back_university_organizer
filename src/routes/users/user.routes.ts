// =====================================================
// users/user.routes.ts
// =====================================================
import { Router } from "express";
import * as userController from "../../controllers/users/user.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// RUTAS PÚBLICAS
// =====================================================
// Nota: La creación de usuarios normalmente se hace vía /auth/register
// Esta ruta está protegida para uso administrativo
router.post("/", requireAuth, userController.create);

// =====================================================
// RUTAS PROTEGIDAS (requieren autenticación)
// =====================================================

// Búsqueda de usuarios
router.get("/search", requireAuth, userController.search);

// Listar todos los usuarios (con paginación)
router.get("/", requireAuth, userController.getAll);

// Obtener usuario por ID
router.get("/:id", requireAuth, userController.getById);

// Obtener estadísticas del usuario
router.get("/:id/stats", requireAuth, userController.getStats);

// Actualizar usuario
router.put("/:id", requireAuth, userController.update);

// Actualizar contraseña
router.put("/:id/password", requireAuth, userController.updatePassword);

// Eliminar usuario (soft delete)
router.delete("/:id", requireAuth, userController.softDelete);

// Activar usuario
router.post("/:id/activate", requireAuth, userController.activate);

// Desactivar usuario
router.post("/:id/deactivate", requireAuth, userController.deactivate);

// Restaurar usuario eliminado
router.post("/:id/restore", requireAuth, userController.restore);

export default router;
