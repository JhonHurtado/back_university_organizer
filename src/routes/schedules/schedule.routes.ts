// =====================================================
// routes/schedules/schedule.routes.ts
// =====================================================
import { Router } from "express";
import * as scheduleController from "../../controllers/schedules/schedule.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// SCHEDULE ROUTES
// =====================================================
router.post("/schedules", requireAuth, scheduleController.createSchedule);
router.get("/enrollments/:enrollmentId/schedules", requireAuth, scheduleController.getSchedulesByEnrollment);
router.get("/schedules/weekly", requireAuth, scheduleController.getWeeklySchedule);
router.get("/careers/:careerId/schedules/conflicts", requireAuth, scheduleController.checkConflicts);
router.put("/schedules/:id", requireAuth, scheduleController.updateSchedule);
router.delete("/schedules/:id", requireAuth, scheduleController.deleteSchedule);

// =====================================================
// SCHEDULE EXCEPTION ROUTES
// =====================================================
router.post("/schedule-exceptions", requireAuth, scheduleController.createException);
router.put("/schedule-exceptions/:id", requireAuth, scheduleController.updateException);
router.delete("/schedule-exceptions/:id", requireAuth, scheduleController.deleteException);

export default router;
