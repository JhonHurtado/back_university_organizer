// =====================================================
// routes/verification/verification.routes.ts
// =====================================================
import { Router } from "express";
import * as verificationController from "../../controllers/verification/verification.controller";

const router = Router();

// =====================================================
// VERIFICATION ROUTES (PUBLIC)
// =====================================================

// Verificar email
router.get("/verify-email", verificationController.verifyEmail);

// Reenviar email de verificación
router.post("/resend-verification", verificationController.resendVerificationEmail);

// Solicitar reset de contraseña
router.post("/request-password-reset", verificationController.requestPasswordReset);

// Resetear contraseña
router.post("/reset-password", verificationController.resetPassword);

export default router;
