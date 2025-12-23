// =====================================================
// types/schemas/analytics/analytics.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// CAREER ANALYTICS QUERY SCHEMA
// =====================================================
export const careerAnalyticsQuerySchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  periodId: z.string().uuid("ID de período inválido").optional(),
});

// =====================================================
// SEMESTER ANALYTICS QUERY SCHEMA
// =====================================================
export const semesterAnalyticsQuerySchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  semesterNumber: z.coerce.number().int().positive("Número de semestre inválido"),
});

// =====================================================
// SUBJECT TYPE FILTER SCHEMA
// =====================================================
export const subjectTypeFilterSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  subjectType: z.enum(["REQUIRED", "ELECTIVE", "FREE_ELECTIVE", "COMPLEMENTARY"]).optional(),
});

// =====================================================
// GPA PREDICTION SCHEMA
// =====================================================
export const gpaPredictionSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  targetGrades: z.array(z.object({
    subjectId: z.string().uuid("ID de materia inválido"),
    expectedGrade: z.number().min(0).max(100),
  })).optional(),
});

// =====================================================
// SUBJECT RECOMMENDATION PARAMS SCHEMA
// =====================================================
export const subjectRecommendationSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  limit: z.coerce.number().int().positive().max(20).default(5).optional(),
});

// =====================================================
// PERFORMANCE TREND SCHEMA
// =====================================================
export const performanceTrendSchema = z.object({
  careerId: z.string().uuid("ID de carrera inválido"),
  periods: z.coerce.number().int().positive().max(10).default(5).optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CareerAnalyticsQueryInput = z.infer<typeof careerAnalyticsQuerySchema>;
export type SemesterAnalyticsQueryInput = z.infer<typeof semesterAnalyticsQuerySchema>;
export type SubjectTypeFilterInput = z.infer<typeof subjectTypeFilterSchema>;
export type GPAPredictionInput = z.infer<typeof gpaPredictionSchema>;
export type SubjectRecommendationInput = z.infer<typeof subjectRecommendationSchema>;
export type PerformanceTrendInput = z.infer<typeof performanceTrendSchema>;
