// =====================================================
// routes/menus/menu.routes.ts
// =====================================================
import { Router } from "express";
import * as menuController from "../../controllers/menus/menu.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// =====================================================

// Get menu tree for authenticated user (with plan permissions)
router.get("/user/tree", requireAuth, menuController.getMenuTreeByUser);

// Get hierarchical menu tree (all active menus)
router.get("/tree", requireAuth, menuController.getMenuTree);

// Get all menus (flat list)
router.get("/", requireAuth, menuController.getAll);

// Create menu
router.post("/", requireAuth, menuController.create);

// Plan menu access management
router.post("/access", requireAuth, menuController.assignPlanAccess);
router.put("/access", requireAuth, menuController.updatePlanAccess);
router.delete("/access", requireAuth, menuController.removePlanAccess);
router.get("/access/:planId", requireAuth, menuController.getPlanAccess);

// Get menu by ID
router.get("/:id", requireAuth, menuController.getById);

// Update menu
router.put("/:id", requireAuth, menuController.update);

// Delete menu (soft delete)
router.delete("/:id", requireAuth, menuController.softDelete);

// Restore menu
router.post("/:id/restore", requireAuth, menuController.restore);

export default router;
