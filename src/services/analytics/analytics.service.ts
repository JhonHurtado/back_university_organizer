// =====================================================
// services/analytics/analytics.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type { GradeScale } from "@prisma/client";

// =====================================================
// ANALYTICS SERVICE
// =====================================================
class AnalyticsService {
  // =====================================================
  // GET CAREER STATISTICS BY PERIOD
  // =====================================================
  async getCareerStatisticsByPeriod(userId: string, careerId: string, periodId?: string) {
    // Verificar que la carrera pertenece al usuario
    const career = await database.career.findFirst({
      where: { id: careerId, userId },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Construir filtro de período
    const periodFilter: any = periodId
      ? { academicPeriodId: periodId }
      : {};

    // Obtener todas las inscripciones del período
    const enrollments = await database.subjectEnrollment.findMany({
      where: {
        subject: { careerId },
        ...periodFilter,
        state: "A",
      },
      include: {
        subject: true,
        grades: {
          where: { state: "A" },
        },
        academicPeriod: true,
      },
    });

    // Calcular estadísticas
    const totalSubjects = enrollments.length;
    const passedSubjects = enrollments.filter((e) => e.isPassed === true).length;
    const failedSubjects = enrollments.filter((e) => e.isPassed === false).length;
    const inProgressSubjects = enrollments.filter((e) => e.status === "IN_PROGRESS").length;

    // Calcular promedio general
    const gradesWithFinal = enrollments.filter((e) => e.finalGrade !== null);
    const averageGrade =
      gradesWithFinal.length > 0
        ? gradesWithFinal.reduce((sum, e) => sum + Number(e.finalGrade), 0) / gradesWithFinal.length
        : 0;

    // Calcular GPA
    const gpa = this.convertToGPA(averageGrade, career.gradeScale);

    // Calcular créditos
    const totalCredits = enrollments.reduce((sum, e) => sum + e.subject.credits, 0);
    const earnedCredits = enrollments
      .filter((e) => e.isPassed === true)
      .reduce((sum, e) => sum + e.subject.credits, 0);

    // Agrupar por tipo de materia
    const bySubjectType = enrollments.reduce((acc, e) => {
      const type = e.subject.subjectType;
      if (!acc[type]) {
        acc[type] = {
          count: 0,
          passed: 0,
          failed: 0,
          averageGrade: 0,
          grades: [],
        };
      }
      acc[type].count++;
      if (e.isPassed === true) acc[type].passed++;
      if (e.isPassed === false) acc[type].failed++;
      if (e.finalGrade) acc[type].grades.push(Number(e.finalGrade));
      return acc;
    }, {} as Record<string, any>);

    // Calcular promedio por tipo
    Object.keys(bySubjectType).forEach((type) => {
      const grades = bySubjectType[type].grades;
      bySubjectType[type].averageGrade =
        grades.length > 0 ? grades.reduce((a: number, b: number) => a + b, 0) / grades.length : 0;
      delete bySubjectType[type].grades; // Limpiar array temporal
    });

    return {
      careerId,
      periodId,
      totalSubjects,
      passedSubjects,
      failedSubjects,
      inProgressSubjects,
      averageGrade: Number(averageGrade.toFixed(2)),
      gpa: Number(gpa.toFixed(2)),
      totalCredits,
      earnedCredits,
      bySubjectType,
    };
  }

  // =====================================================
  // PREDICT GPA
  // =====================================================
  async predictGPA(
    userId: string,
    careerId: string,
    targetGrades?: Array<{ subjectId: string; expectedGrade: number }>
  ) {
    // Verificar que la carrera pertenece al usuario
    const career = await database.career.findFirst({
      where: { id: careerId, userId },
      include: {
        subjects: {
          where: { state: "A" },
          include: {
            enrollments: {
              where: { state: "A" },
              include: {
                grades: {
                  where: { state: "A" },
                },
              },
            },
          },
        },
      },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Obtener todas las inscripciones completadas
    const completedEnrollments = career.subjects.flatMap((s) =>
      s.enrollments.filter((e) => e.finalGrade !== null)
    );

    // Calcular GPA actual
    const currentAverage =
      completedEnrollments.length > 0
        ? completedEnrollments.reduce((sum, e) => sum + Number(e.finalGrade), 0) /
          completedEnrollments.length
        : 0;

    const currentGPA = this.convertToGPA(currentAverage, career.gradeScale);

    // Calcular GPA proyectado si hay target grades
    if (targetGrades && targetGrades.length > 0) {
      const allGrades = [
        ...completedEnrollments.map((e) => Number(e.finalGrade)),
        ...targetGrades.map((t) => t.expectedGrade),
      ];

      const projectedAverage = allGrades.reduce((a, b) => a + b, 0) / allGrades.length;
      const projectedGPA = this.convertToGPA(projectedAverage, career.gradeScale);

      return {
        currentGPA: Number(currentGPA.toFixed(2)),
        projectedGPA: Number(projectedGPA.toFixed(2)),
        improvementNeeded: Number((projectedGPA - currentGPA).toFixed(2)),
        completedSubjects: completedEnrollments.length,
        targetSubjects: targetGrades.length,
        totalSubjects: completedEnrollments.length + targetGrades.length,
      };
    }

    // Si no hay target grades, calcular qué se necesita para mejorar el GPA
    const targetGPAs = [3.0, 3.5, 4.0];
    const recommendations = targetGPAs.map((targetGPA) => {
      const targetAverage = this.convertFromGPA(targetGPA, career.gradeScale);
      const totalSubjects = completedEnrollments.length + 1;
      const requiredGrade =
        targetAverage * totalSubjects - currentAverage * completedEnrollments.length;

      return {
        targetGPA,
        requiredGrade: Number(Math.max(0, requiredGrade).toFixed(2)),
        achievable: requiredGrade <= Number(career.maxGrade),
      };
    });

    return {
      currentGPA: Number(currentGPA.toFixed(2)),
      completedSubjects: completedEnrollments.length,
      recommendations,
    };
  }

  // =====================================================
  // GET SUBJECT RECOMMENDATIONS
  // =====================================================
  async getSubjectRecommendations(userId: string, careerId: string, limit: number = 5) {
    // Verificar que la carrera pertenece al usuario
    const career = await database.career.findFirst({
      where: { id: careerId, userId },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Obtener materias aprobadas
    const passedSubjects = await database.subjectEnrollment.findMany({
      where: {
        subject: { careerId },
        isPassed: true,
        state: "A",
      },
      select: {
        subjectId: true,
      },
    });

    const passedSubjectIds = passedSubjects.map((e) => e.subjectId);

    // Obtener materias inscritas actualmente
    const enrolledSubjects = await database.subjectEnrollment.findMany({
      where: {
        subject: { careerId },
        status: { in: ["ENROLLED", "IN_PROGRESS"] },
        state: "A",
      },
      select: {
        subjectId: true,
      },
    });

    const enrolledSubjectIds = enrolledSubjects.map((e) => e.subjectId);

    // Obtener todas las materias disponibles
    const allSubjects = await database.subject.findMany({
      where: {
        careerId,
        state: "A",
      },
      include: {
        prerequisites: {
          include: {
            prerequisite: true,
          },
        },
        corequisites: {
          include: {
            corequisite: true,
          },
        },
        semester: true,
      },
    });

    // Filtrar materias que se pueden tomar
    const availableSubjects = allSubjects
      .filter((subject) => {
        // No incluir materias ya aprobadas o inscritas
        if (passedSubjectIds.includes(subject.id) || enrolledSubjectIds.includes(subject.id)) {
          return false;
        }

        // Verificar prerequisitos
        const prerequisitesMet = subject.prerequisites.every((prereq) => {
          if (prereq.isStrict) {
            return passedSubjectIds.includes(prereq.prerequisiteId);
          }
          return true; // Prerequisitos no estrictos se consideran opcionales
        });

        return prerequisitesMet;
      })
      .map((subject) => {
        // Calcular score de recomendación
        let score = 0;

        // Priorizar materias de semestres anteriores
        if (subject.semester.number <= career.currentSemester) {
          score += 10;
        }

        // Priorizar materias obligatorias
        if (subject.subjectType === "REQUIRED") {
          score += 5;
        }

        // Priorizar materias con menos prerequisitos
        score += Math.max(0, 5 - subject.prerequisites.length);

        return {
          ...subject,
          recommendationScore: score,
          reason: this.getRecommendationReason(subject, career.currentSemester),
        };
      })
      .sort((a, b) => b.recommendationScore - a.recommendationScore)
      .slice(0, limit);

    return availableSubjects;
  }

  // =====================================================
  // ANALYZE PERFORMANCE BY SUBJECT TYPE
  // =====================================================
  async analyzePerformanceBySubjectType(userId: string, careerId: string) {
    const career = await database.career.findFirst({
      where: { id: careerId, userId },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    const enrollments = await database.subjectEnrollment.findMany({
      where: {
        subject: { careerId },
        finalGrade: { not: null },
        state: "A",
      },
      include: {
        subject: true,
      },
    });

    const byType = enrollments.reduce((acc, enrollment) => {
      const type = enrollment.subject.subjectType;
      if (!acc[type]) {
        acc[type] = {
          count: 0,
          totalGrade: 0,
          averageGrade: 0,
          highestGrade: 0,
          lowestGrade: Number(career.maxGrade),
          passRate: 0,
          passed: 0,
          failed: 0,
        };
      }

      const grade = Number(enrollment.finalGrade);
      acc[type].count++;
      acc[type].totalGrade += grade;
      acc[type].highestGrade = Math.max(acc[type].highestGrade, grade);
      acc[type].lowestGrade = Math.min(acc[type].lowestGrade, grade);

      if (enrollment.isPassed) {
        acc[type].passed++;
      } else {
        acc[type].failed++;
      }

      return acc;
    }, {} as Record<string, any>);

    // Calcular promedios y pass rate
    Object.keys(byType).forEach((type) => {
      byType[type].averageGrade = Number(
        (byType[type].totalGrade / byType[type].count).toFixed(2)
      );
      byType[type].passRate = Number(
        ((byType[type].passed / byType[type].count) * 100).toFixed(2)
      );
      delete byType[type].totalGrade; // Limpiar dato temporal
    });

    return {
      careerId,
      analysis: byType,
      totalSubjectsAnalyzed: enrollments.length,
    };
  }

  // =====================================================
  // GET PERFORMANCE TRENDS
  // =====================================================
  async getPerformanceTrends(userId: string, careerId: string, periods: number = 5) {
    const career = await database.career.findFirst({
      where: { id: careerId, userId },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Obtener períodos académicos
    const academicPeriods = await database.academicPeriod.findMany({
      where: {
        careerId,
        state: "A",
      },
      orderBy: {
        startDate: "desc",
      },
      take: periods,
      include: {
        subjectEnrollments: {
          where: {
            finalGrade: { not: null },
            state: "A",
          },
          include: {
            subject: true,
          },
        },
      },
    });

    const trends = academicPeriods.map((period) => {
      const enrollments = period.subjectEnrollments;
      const averageGrade =
        enrollments.length > 0
          ? enrollments.reduce((sum, e) => sum + Number(e.finalGrade), 0) / enrollments.length
          : 0;

      const gpa = this.convertToGPA(averageGrade, career.gradeScale);
      const passed = enrollments.filter((e) => e.isPassed === true).length;
      const failed = enrollments.filter((e) => e.isPassed === false).length;
      const totalCredits = enrollments.reduce((sum, e) => sum + e.subject.credits, 0);

      return {
        periodId: period.id,
        periodName: period.name,
        year: period.year,
        period: period.period,
        startDate: period.startDate,
        endDate: period.endDate,
        totalSubjects: enrollments.length,
        passedSubjects: passed,
        failedSubjects: failed,
        averageGrade: Number(averageGrade.toFixed(2)),
        gpa: Number(gpa.toFixed(2)),
        totalCredits,
        passRate: enrollments.length > 0 ? Number(((passed / enrollments.length) * 100).toFixed(2)) : 0,
      };
    });

    // Calcular tendencia general
    const avgGpaChange =
      trends.length > 1
        ? Number(((trends[0].gpa - trends[trends.length - 1].gpa) / (trends.length - 1)).toFixed(3))
        : 0;

    return {
      careerId,
      trends: trends.reverse(), // Ordenar cronológicamente
      summary: {
        periodsAnalyzed: trends.length,
        averageGPAChange: avgGpaChange,
        trend: avgGpaChange > 0 ? "improving" : avgGpaChange < 0 ? "declining" : "stable",
      },
    };
  }

  // =====================================================
  // HELPER: Convert grade to GPA
  // =====================================================
  private convertToGPA(grade: number, scale: GradeScale): number {
    switch (scale) {
      case "FIVE":
        return (grade / 5) * 4;
      case "TEN":
        return (grade / 10) * 4;
      case "HUNDRED":
        return (grade / 100) * 4;
      case "FOUR_GPA":
        return grade;
      case "SEVEN":
        return ((grade - 1) / 6) * 4;
      default:
        return grade;
    }
  }

  // =====================================================
  // HELPER: Convert GPA to grade
  // =====================================================
  private convertFromGPA(gpa: number, scale: GradeScale): number {
    switch (scale) {
      case "FIVE":
        return (gpa / 4) * 5;
      case "TEN":
        return (gpa / 4) * 10;
      case "HUNDRED":
        return (gpa / 4) * 100;
      case "FOUR_GPA":
        return gpa;
      case "SEVEN":
        return (gpa / 4) * 6 + 1;
      default:
        return gpa;
    }
  }

  // =====================================================
  // HELPER: Get recommendation reason
  // =====================================================
  private getRecommendationReason(subject: any, currentSemester: number): string {
    const reasons = [];

    if (subject.semester.number <= currentSemester) {
      reasons.push("Corresponde a tu semestre actual o anterior");
    }

    if (subject.subjectType === "REQUIRED") {
      reasons.push("Es una materia obligatoria");
    }

    if (subject.prerequisites.length === 0) {
      reasons.push("No tiene prerequisitos");
    }

    if (reasons.length === 0) {
      reasons.push("Materia disponible para inscripción");
    }

    return reasons.join(". ") + ".";
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const analyticsService = new AnalyticsService();
