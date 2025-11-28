// =====================================================
// apiClient.routes.ts
// =====================================================
import { Router } from "express";
import * as apiClientController from "../../controllers/clients/apiClient.controller";
// import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// Todas las rutas requieren autenticación
// router.use(requireAuth);

router.post("/", apiClientController.create);
router.get("/", apiClientController.getAll);
router.get("/:id", apiClientController.getById);
router.patch("/:id", apiClientController.update);
router.post("/:id/regenerate-secret", apiClientController.regenerateSecret);
router.post("/:id/deactivate", apiClientController.deactivate);
router.post("/:id/activate", apiClientController.activate);

export default router;
