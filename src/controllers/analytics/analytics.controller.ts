// =====================================================
// controllers/analytics/analytics.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { analyticsService } from "@/services/analytics/analytics.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as analyticsSchemas from "@/types/schemas/analytics/analytics.schemas";

// =====================================================
// ANALYTICS CONTROLLERS
// =====================================================

/**
 * Obtener estadísticas de carrera por período
 */
export async function getCareerStatistics(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId, periodId } = analyticsSchemas.careerAnalyticsQuerySchema.parse(req.query);

    const stats = await analyticsService.getCareerStatisticsByPeriod(userId, careerId, periodId);

    return sendSuccess({
      res,
      message: "Estadísticas obtenidas exitosamente",
      data: stats,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    if (error.message === "CAREER_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al obtener estadísticas",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Predecir GPA
 */
export async function predictGPA(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId, targetGrades } = analyticsSchemas.gpaPredictionSchema.parse(req.body);

    const prediction = await analyticsService.predictGPA(userId, careerId, targetGrades);

    return sendSuccess({
      res,
      message: "Predicción de GPA calculada exitosamente",
      data: prediction,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    if (error.message === "CAREER_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al predecir GPA",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener recomendaciones de materias
 */
export async function getSubjectRecommendations(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId, limit } = analyticsSchemas.subjectRecommendationSchema.parse(req.query);

    const recommendations = await analyticsService.getSubjectRecommendations(
      userId,
      careerId,
      limit || 5
    );

    return sendSuccess({
      res,
      message: "Recomendaciones obtenidas exitosamente",
      data: {
        count: recommendations.length,
        recommendations,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    if (error.message === "CAREER_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al obtener recomendaciones",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Analizar rendimiento por tipo de materia
 */
export async function analyzePerformanceByType(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = analyticsSchemas.subjectTypeFilterSchema.parse(req.query);

    const analysis = await analyticsService.analyzePerformanceBySubjectType(userId, careerId);

    return sendSuccess({
      res,
      message: "Análisis de rendimiento obtenido exitosamente",
      data: analysis,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    if (error.message === "CAREER_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al analizar rendimiento",
      error: "SERVER_ERROR",
    });
  }
}

/**
 * Obtener tendencias de rendimiento
 */
export async function getPerformanceTrends(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId, periods } = analyticsSchemas.performanceTrendSchema.parse(req.query);

    const trends = await analyticsService.getPerformanceTrends(userId, careerId, periods || 5);

    return sendSuccess({
      res,
      message: "Tendencias de rendimiento obtenidas exitosamente",
      data: trends,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    if (error.message === "CAREER_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Carrera no encontrada", error: error.message });
    }
    return sendError({
      res,
      code: 500,
      message: "Error al obtener tendencias",
      error: "SERVER_ERROR",
    });
  }
}
