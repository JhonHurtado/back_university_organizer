// =====================================================
// routes/analytics/analytics.routes.ts
// =====================================================
import { Router } from "express";
import * as analyticsController from "../../controllers/analytics/analytics.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// ANALYTICS ROUTES (ALL PROTECTED)
// =====================================================

// Obtener estadísticas de carrera por período
router.get("/career/statistics", requireAuth, analyticsController.getCareerStatistics);

// Predecir GPA
router.post("/gpa/predict", requireAuth, analyticsController.predictGPA);

// Obtener recomendaciones de materias
router.get("/subjects/recommendations", requireAuth, analyticsController.getSubjectRecommendations);

// Analizar rendimiento por tipo de materia
router.get("/performance/by-type", requireAuth, analyticsController.analyzePerformanceByType);

// Obtener tendencias de rendimiento
router.get("/performance/trends", requireAuth, analyticsController.getPerformanceTrends);

export default router;
