// =====================================================
// routes/preferences/preference.routes.ts
// =====================================================
import { Router } from "express";
import * as preferenceController from "../../controllers/preferences/preference.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// =====================================================

// Obtener preferencias del usuario autenticado
router.get("/", requireAuth, preferenceController.getPreferences);

// Actualizar preferencias generales
router.put("/", requireAuth, preferenceController.updatePreferences);

// Actualizar preferencias de notificación
router.put(
  "/notifications",
  requireAuth,
  preferenceController.updateNotificationPreferences
);

// Actualizar preferencias de visualización
router.put(
  "/display",
  requireAuth,
  preferenceController.updateDisplayPreferences
);

// Actualizar preferencias académicas
router.put(
  "/academic",
  requireAuth,
  preferenceController.updateAcademicPreferences
);

export default router;
