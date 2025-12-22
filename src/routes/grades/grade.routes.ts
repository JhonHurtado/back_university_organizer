// =====================================================
// routes/grades/grade.routes.ts
// =====================================================
import { Router } from "express";
import * as gradeController from "../../controllers/grades/grade.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// GRADE ROUTES
// =====================================================
router.post("/grades", requireAuth, gradeController.createGrade);
router.get("/enrollments/:enrollmentId/grades", requireAuth, gradeController.getGradesByEnrollment);
router.put("/grades/:id", requireAuth, gradeController.updateGrade);
router.delete("/grades/:id", requireAuth, gradeController.deleteGrade);

// =====================================================
// GRADE ITEM ROUTES
// =====================================================
router.post("/grade-items", requireAuth, gradeController.createGradeItem);
router.put("/grade-items/:id", requireAuth, gradeController.updateGradeItem);
router.delete("/grade-items/:id", requireAuth, gradeController.deleteGradeItem);

// =====================================================
// GPA ROUTES
// =====================================================
router.get("/careers/:careerId/gpa", requireAuth, gradeController.getCareerGPA);

export default router;
