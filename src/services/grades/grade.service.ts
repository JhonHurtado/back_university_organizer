// =====================================================
// services/grades/grade.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateGradeInput,
  UpdateGradeInput,
  CreateGradeItemInput,
  UpdateGradeItemInput,
} from "@/types/schemas/grades/grade.schemas";
import type { Grade, GradeItem } from "@prisma/client";
import { Decimal } from "@prisma/client/runtime/library";

// =====================================================
// GRADE SERVICE
// =====================================================
class GradeService {
  // =====================================================
  // CREATE GRADE
  // =====================================================
  async createGrade(userId: string, data: CreateGradeInput): Promise<Grade> {
    // Verificar que la inscripción existe y pertenece al usuario
    const enrollment = await database.subjectEnrollment.findFirst({
      where: {
        id: data.enrollmentId,
      },
      include: {
        subject: {
          include: {
            career: true,
          },
        },
      },
    });

    if (!enrollment) {
      throw new Error("ENROLLMENT_NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar que el número de corte no exceda el total de cortes de la materia
    if (data.cutNumber > enrollment.subject.totalCuts) {
      throw new Error("INVALID_CUT_NUMBER");
    }

    // Verificar que no exista ya una nota para este corte
    const existing = await database.grade.findUnique({
      where: {
        enrollmentId_cutNumber: {
          enrollmentId: data.enrollmentId,
          cutNumber: data.cutNumber,
        },
      },
    });

    if (existing) {
      throw new Error("GRADE_ALREADY_EXISTS");
    }

    // Validar que la nota no exceda la nota máxima
    if (data.grade > data.maxGrade) {
      throw new Error("GRADE_EXCEEDS_MAX");
    }

    // Calcular nota ponderada
    const weightedGrade = this.calculateWeightedGrade(
      data.grade,
      data.weight,
      data.maxGrade
    );

    const grade = await database.grade.create({
      data: {
        ...data,
        weightedGrade: new Decimal(weightedGrade),
      },
    });

    // Recalcular nota final de la inscripción
    await this.updateEnrollmentFinalGrade(data.enrollmentId);

    return grade;
  }

  // =====================================================
  // UPDATE GRADE
  // =====================================================
  async updateGrade(
    userId: string,
    id: string,
    data: UpdateGradeInput
  ): Promise<Grade> {
    // Verificar que la nota existe y pertenece al usuario
    const grade = await database.grade.findFirst({
      where: { id },
      include: {
        enrollment: {
          include: {
            subject: {
              include: {
                career: true,
              },
            },
          },
        },
      },
    });

    if (!grade) {
      throw new Error("NOT_FOUND");
    }

    if (grade.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar que la nota no exceda la nota máxima
    const newGrade = data.grade ?? Number(grade.grade);
    const newMaxGrade = data.maxGrade ?? Number(grade.maxGrade);
    if (newGrade > newMaxGrade) {
      throw new Error("GRADE_EXCEEDS_MAX");
    }

    // Recalcular nota ponderada si cambiaron grade o weight
    let updateData: any = { ...data };
    if (data.grade !== undefined || data.weight !== undefined) {
      const finalGrade = data.grade ?? Number(grade.grade);
      const finalWeight = data.weight ?? Number(grade.weight);
      const finalMaxGrade = data.maxGrade ?? Number(grade.maxGrade);

      const weightedGrade = this.calculateWeightedGrade(
        finalGrade,
        finalWeight,
        finalMaxGrade
      );
      updateData.weightedGrade = new Decimal(weightedGrade);
    }

    const updated = await database.grade.update({
      where: { id },
      data: updateData,
    });

    // Recalcular nota final de la inscripción
    await this.updateEnrollmentFinalGrade(grade.enrollmentId);

    return updated;
  }

  // =====================================================
  // DELETE GRADE
  // =====================================================
  async deleteGrade(userId: string, id: string): Promise<void> {
    const grade = await database.grade.findFirst({
      where: { id },
      include: {
        enrollment: {
          include: {
            subject: {
              include: {
                career: true,
              },
            },
          },
        },
      },
    });

    if (!grade) {
      throw new Error("NOT_FOUND");
    }

    if (grade.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    const enrollmentId = grade.enrollmentId;

    await database.grade.update({
      where: { id },
      data: { state: "I" },
    });

    // Recalcular nota final
    await this.updateEnrollmentFinalGrade(enrollmentId);
  }

  // =====================================================
  // GET GRADES BY ENROLLMENT
  // =====================================================
  async getGradesByEnrollment(userId: string, enrollmentId: string): Promise<Grade[]> {
    // Verificar que la inscripción pertenece al usuario
    const enrollment = await database.subjectEnrollment.findFirst({
      where: { id: enrollmentId },
      include: {
        subject: {
          include: {
            career: true,
          },
        },
      },
    });

    if (!enrollment) {
      throw new Error("ENROLLMENT_NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    const grades = await database.grade.findMany({
      where: {
        enrollmentId,
        state: "A",
      },
      orderBy: {
        cutNumber: "asc",
      },
      include: {
        gradeItems: {
          where: {
            state: "A",
          },
          orderBy: {
            createdAt: "asc",
          },
        },
      },
    });

    return grades;
  }

  // =====================================================
  // CREATE GRADE ITEM
  // =====================================================
  async createGradeItem(userId: string, data: CreateGradeItemInput): Promise<GradeItem> {
    // Verificar que la nota existe y pertenece al usuario
    const grade = await database.grade.findFirst({
      where: { id: data.gradeId },
      include: {
        enrollment: {
          include: {
            subject: {
              include: {
                career: true,
              },
            },
          },
        },
      },
    });

    if (!grade) {
      throw new Error("GRADE_NOT_FOUND");
    }

    if (grade.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar que la nota no exceda la nota máxima
    if (data.grade > data.maxGrade) {
      throw new Error("GRADE_EXCEEDS_MAX");
    }

    const gradeItem = await database.gradeItem.create({
      data,
    });

    return gradeItem;
  }

  // =====================================================
  // UPDATE GRADE ITEM
  // =====================================================
  async updateGradeItem(
    userId: string,
    id: string,
    data: UpdateGradeItemInput
  ): Promise<GradeItem> {
    const gradeItem = await database.gradeItem.findFirst({
      where: { id },
      include: {
        gradeRecord: {
          include: {
            enrollment: {
              include: {
                subject: {
                  include: {
                    career: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!gradeItem) {
      throw new Error("NOT_FOUND");
    }

    if (gradeItem.gradeRecord.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar que la nota no exceda la nota máxima
    const newGrade = data.grade ?? Number(gradeItem.grade);
    const newMaxGrade = data.maxGrade ?? Number(gradeItem.maxGrade);
    if (newGrade > newMaxGrade) {
      throw new Error("GRADE_EXCEEDS_MAX");
    }

    const updated = await database.gradeItem.update({
      where: { id },
      data,
    });

    return updated;
  }

  // =====================================================
  // DELETE GRADE ITEM
  // =====================================================
  async deleteGradeItem(userId: string, id: string): Promise<void> {
    const gradeItem = await database.gradeItem.findFirst({
      where: { id },
      include: {
        gradeRecord: {
          include: {
            enrollment: {
              include: {
                subject: {
                  include: {
                    career: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!gradeItem) {
      throw new Error("NOT_FOUND");
    }

    if (gradeItem.gradeRecord.enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.gradeItem.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // GET CAREER GPA
  // =====================================================
  async getCareerGPA(userId: string, careerId: string) {
    // Verificar que la carrera pertenece al usuario
    const career = await database.career.findFirst({
      where: {
        id: careerId,
        userId,
        deletedAt: null,
      },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Obtener todas las inscripciones completadas con sus notas
    const enrollments = await database.subjectEnrollment.findMany({
      where: {
        subject: {
          careerId,
        },
        status: { in: ["COMPLETED", "PASSED", "FAILED"] },
        finalGrade: { not: null },
      },
      include: {
        subject: true,
        grades: {
          where: { state: "A" },
        },
      },
    });

    if (enrollments.length === 0) {
      return {
        gpa: 0,
        totalCredits: 0,
        completedCredits: 0,
        averageGrade: 0,
        passedSubjects: 0,
        failedSubjects: 0,
      };
    }

    let totalWeightedGrade = 0;
    let totalCredits = 0;
    let passedSubjects = 0;
    let failedSubjects = 0;

    enrollments.forEach((enrollment) => {
      const credits = enrollment.subject.credits;
      const finalGrade = Number(enrollment.finalGrade);

      totalWeightedGrade += finalGrade * credits;
      totalCredits += credits;

      const minPassingGrade = Number(career.minPassingGrade);
      if (finalGrade >= minPassingGrade) {
        passedSubjects++;
      } else {
        failedSubjects++;
      }
    });

    const averageGrade = totalCredits > 0 ? totalWeightedGrade / totalCredits : 0;

    // Calcular GPA según la escala
    const gpa = this.convertToGPA(averageGrade, career.gradeScale as string);

    return {
      gpa: Number(gpa.toFixed(2)),
      totalCredits: career.totalCredits,
      completedCredits: totalCredits,
      averageGrade: Number(averageGrade.toFixed(2)),
      passedSubjects,
      failedSubjects,
      totalSubjects: enrollments.length,
    };
  }

  // =====================================================
  // HELPER: CALCULATE WEIGHTED GRADE
  // =====================================================
  private calculateWeightedGrade(
    grade: number,
    weight: number,
    maxGrade: number = 5.0
  ): number {
    // Normalizar a escala 0-100
    const normalizedGrade = (grade / maxGrade) * 100;
    // Aplicar peso
    const weighted = (normalizedGrade * weight) / 100;
    return weighted;
  }

  // =====================================================
  // HELPER: UPDATE ENROLLMENT FINAL GRADE
  // =====================================================
  private async updateEnrollmentFinalGrade(enrollmentId: string): Promise<void> {
    const grades = await database.grade.findMany({
      where: {
        enrollmentId,
        state: "A",
      },
    });

    if (grades.length === 0) {
      // Sin notas, limpiar nota final
      await database.subjectEnrollment.update({
        where: { id: enrollmentId },
        data: {
          finalGrade: null,
          isPassed: null,
        },
      });
      return;
    }

    // Sumar todas las notas ponderadas
    const totalWeighted = grades.reduce(
      (sum, g) => sum + Number(g.weightedGrade || 0),
      0
    );

    // Obtener datos de la inscripción para validar aprobación
    const enrollment = await database.subjectEnrollment.findUnique({
      where: { id: enrollmentId },
      include: {
        subject: {
          include: {
            career: true,
          },
        },
      },
    });

    if (!enrollment) return;

    // La nota final es la suma de las ponderadas (ya están en escala 0-100)
    // Convertir de vuelta a la escala de la carrera
    const maxGrade = Number(enrollment.subject.career.maxGrade);
    const finalGrade = (totalWeighted * maxGrade) / 100;

    const minPassingGrade = Number(enrollment.subject.career.minPassingGrade);
    const isPassed = finalGrade >= minPassingGrade;

    await database.subjectEnrollment.update({
      where: { id: enrollmentId },
      data: {
        finalGrade: new Decimal(finalGrade),
        isPassed,
        status: isPassed ? "PASSED" : "FAILED",
      },
    });
  }

  // =====================================================
  // HELPER: CONVERT TO GPA
  // =====================================================
  private convertToGPA(grade: number, scale: string): number {
    switch (scale) {
      case "FIVE":
        // 0-5 -> 0-4 GPA
        return (grade / 5) * 4;
      case "TEN":
        // 0-10 -> 0-4 GPA
        return (grade / 10) * 4;
      case "HUNDRED":
        // 0-100 -> 0-4 GPA
        return (grade / 100) * 4;
      case "FOUR_GPA":
        // Ya es GPA
        return grade;
      case "SEVEN":
        // 1-7 -> 0-4 GPA
        return ((grade - 1) / 6) * 4;
      default:
        return 0;
    }
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const gradeService = new GradeService();
