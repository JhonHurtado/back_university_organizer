// =====================================================
// auth.routes.ts
// =====================================================
import { Router } from "express";
import passport from "../../config/auth/passport";
import * as authController from "../../controllers/auth/auth.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// Públicas (requieren client credentials)
router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/refresh", authController.refresh);
router.post("/google", authController.googleAuth);

// Google OAuth (flujo redirect)
router.get(
  "/google/redirect",
  passport.authenticate("google", {
    scope: ["profile", "email"],
    session: false,
  })
);
router.get("/google/callback", authController.googleCallback);

// Protegidas (requieren Bearer token)
router.get("/me", requireAuth, authController.me);
router.post("/logout", requireAuth, authController.logout);
router.post("/logout-all", requireAuth, authController.logoutAll);

export default router;
