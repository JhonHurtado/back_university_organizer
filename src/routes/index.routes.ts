// =====================================================
// routes/index.ts
// =====================================================
import { Router } from "express";
import authRoutes from "./auth/auth.routes";
import clientRoutes from "./clients/apiClients.routes";
import userRoutes from "./users/user.routes";
import careerRoutes from "./careers/career.routes";
import academicRoutes from "./academic/academic.routes";
import gradeRoutes from "./grades/grade.routes";
import scheduleRoutes from "./schedules/schedule.routes";
import notificationRoutes from "./notifications/notification.routes";
import subscriptionRoutes from "./subscriptions/subscription.routes";
import paymentRoutes from "./payments/payment.routes";
import preferenceRoutes from "./preferences/preference.routes";
import professorRoutes from "./professors/professor.routes";
import menuRoutes from "./menus/menu.routes";
import activityLogRoutes from "./activityLogs/activityLog.routes";
import verificationRoutes from "./verification/verification.routes";
import analyticsRoutes from "./analytics/analytics.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/clients", clientRoutes);
router.use("/users", userRoutes);
router.use("/careers", careerRoutes);
router.use("/academic", academicRoutes);
router.use("/grades", gradeRoutes);
router.use("/schedules", scheduleRoutes);
router.use("/notifications", notificationRoutes);
router.use("/subscriptions", subscriptionRoutes);
router.use("/payments", paymentRoutes);
router.use("/preferences", preferenceRoutes);
router.use("/professors", professorRoutes);
router.use("/menus", menuRoutes);
router.use("/activity-logs", activityLogRoutes);
router.use("/verification", verificationRoutes);
router.use("/analytics", analyticsRoutes);

export default router;
