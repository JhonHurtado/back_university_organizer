// =====================================================
// routes/academic/academic.routes.ts
// =====================================================
import { Router } from "express";
import * as academicController from "../../controllers/academic/academic.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// SEMESTER ROUTES
// =====================================================
router.post("/semesters", requireAuth, academicController.createSemester);
router.get("/careers/:careerId/semesters", requireAuth, academicController.getSemestersByCareer);
router.get("/semesters/:id", requireAuth, academicController.getSemesterById);
router.put("/semesters/:id", requireAuth, academicController.updateSemester);
router.delete("/semesters/:id", requireAuth, academicController.deleteSemester);

// =====================================================
// SUBJECT ROUTES
// =====================================================
router.post("/subjects", requireAuth, academicController.createSubject);
router.get("/careers/:careerId/subjects", requireAuth, academicController.getSubjectsByCareer);
router.get("/subjects/:id", requireAuth, academicController.getSubjectById);
router.put("/subjects/:id", requireAuth, academicController.updateSubject);
router.delete("/subjects/:id", requireAuth, academicController.deleteSubject);

// Prerequisites y Corequisites
router.post("/subjects/:id/prerequisites", requireAuth, academicController.addPrerequisite);
router.delete("/subjects/:id/prerequisites/:prerequisiteId", requireAuth, academicController.removePrerequisite);

// =====================================================
// ACADEMIC PERIOD ROUTES
// =====================================================
router.post("/periods", requireAuth, academicController.createPeriod);
router.get("/careers/:careerId/periods", requireAuth, academicController.getPeriodsByCareer);
router.get("/careers/:careerId/periods/current", requireAuth, academicController.getCurrentPeriod);

// =====================================================
// ENROLLMENT ROUTES
// =====================================================
router.post("/enrollments", requireAuth, academicController.enrollSubject);
router.get("/careers/:careerId/enrollments", requireAuth, academicController.getEnrollmentsByCareer);
router.get("/enrollments/:id", requireAuth, academicController.getEnrollmentById);
router.put("/enrollments/:id", requireAuth, academicController.updateEnrollment);
router.post("/enrollments/:id/withdraw", requireAuth, academicController.withdrawEnrollment);

export default router;
