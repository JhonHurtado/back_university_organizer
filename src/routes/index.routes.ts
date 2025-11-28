// =====================================================
// routes/index.ts
// =====================================================
import { Router } from "express";
import authRoutes from "./auth/auth.routes";
import clientRoutes from "./clients/apiClients.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/clients", clientRoutes);

export default router;
