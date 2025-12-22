// =====================================================
// services/careers/career.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateCareerInput,
  UpdateCareerInput,
  CareerQueryInput,
} from "@/types/schemas/careers/career.schemas";
import type { Career } from "generated/prisma/client";

// =====================================================
// CAREER SERVICE
// =====================================================
class CareerService {
  // =====================================================
  // CREATE
  // =====================================================
  async create(userId: string, data: CreateCareerInput): Promise<Career> {
    // Validar que el semestre actual no exceda el total de semestres
    if (data.currentSemester > data.totalSemesters) {
      throw new Error("INVALID_SEMESTER");
    }

    // Validar coherencia de notas
    if (data.minPassingGrade >= data.maxGrade) {
      throw new Error("INVALID_GRADE_RANGE");
    }

    const career = await database.career.create({
      data: {
        ...data,
        userId,
      },
    });

    return career;
  }

  // =====================================================
  // FIND ALL BY USER
  // =====================================================
  async findByUserId(
    userId: string,
    filters?: CareerQueryInput
  ): Promise<{
    careers: Career[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 10;
    const skip = (page - 1) * limit;

    const where = {
      userId,
      deletedAt: null,
      ...(filters?.status && { status: filters.status }),
    };

    const [careers, total] = await Promise.all([
      database.career.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          createdAt: "desc",
        },
        include: {
          semesters: {
            orderBy: {
              number: "asc",
            },
          },
        },
      }),
      database.career.count({ where }),
    ]);

    return {
      careers,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(id: string, userId: string): Promise<Career | null> {
    const career = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: null,
      },
      include: {
        semesters: {
          orderBy: {
            number: "asc",
          },
          include: {
            subjects: {
              orderBy: {
                name: "asc",
              },
            },
          },
        },
      },
    });

    return career;
  }

  // =====================================================
  // UPDATE
  // =====================================================
  async update(
    id: string,
    userId: string,
    data: UpdateCareerInput
  ): Promise<Career> {
    // Verificar que la carrera existe y pertenece al usuario
    const existingCareer = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: null,
      },
    });

    if (!existingCareer) {
      throw new Error("NOT_FOUND");
    }

    // Validar semestre actual si se está actualizando
    if (data.currentSemester) {
      const totalSemesters = data.totalSemesters || existingCareer.totalSemesters;
      if (data.currentSemester > totalSemesters) {
        throw new Error("INVALID_SEMESTER");
      }
    }

    // Validar coherencia de notas si se están actualizando
    const minGrade = data.minPassingGrade || existingCareer.minPassingGrade;
    const maxGrade = data.maxGrade || existingCareer.maxGrade;

    if (Number(minGrade) >= Number(maxGrade)) {
      throw new Error("INVALID_GRADE_RANGE");
    }

    const career = await database.career.update({
      where: { id },
      data,
    });

    return career;
  }

  // =====================================================
  // UPDATE CURRENT SEMESTER
  // =====================================================
  async updateCurrentSemester(
    id: string,
    userId: string,
    currentSemester: number
  ): Promise<Career> {
    // Verificar que la carrera existe y pertenece al usuario
    const existingCareer = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: null,
      },
    });

    if (!existingCareer) {
      throw new Error("NOT_FOUND");
    }

    // Validar que el semestre no exceda el total
    if (currentSemester > existingCareer.totalSemesters) {
      throw new Error("INVALID_SEMESTER");
    }

    const career = await database.career.update({
      where: { id },
      data: { currentSemester },
    });

    return career;
  }

  // =====================================================
  // SOFT DELETE
  // =====================================================
  async softDelete(id: string, userId: string): Promise<void> {
    // Verificar que la carrera existe y pertenece al usuario
    const existingCareer = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: null,
      },
    });

    if (!existingCareer) {
      throw new Error("NOT_FOUND");
    }

    await database.career.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        state: "I",
      },
    });
  }

  // =====================================================
  // RESTORE
  // =====================================================
  async restore(id: string, userId: string): Promise<Career> {
    // Verificar que la carrera existe, pertenece al usuario y está eliminada
    const existingCareer = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: { not: null },
      },
    });

    if (!existingCareer) {
      throw new Error("NOT_FOUND");
    }

    const career = await database.career.update({
      where: { id },
      data: {
        deletedAt: null,
        state: "A",
      },
    });

    return career;
  }

  // =====================================================
  // GET CAREER STATISTICS
  // =====================================================
  async getCareerStats(id: string, userId: string) {
    const career = await database.career.findFirst({
      where: {
        id,
        userId,
        deletedAt: null,
      },
      include: {
        semesters: {
          include: {
            subjects: {
              include: {
                enrollments: {
                  include: {
                    grades: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!career) {
      throw new Error("NOT_FOUND");
    }

    // Calcular estadísticas
    let totalSubjects = 0;
    let completedSubjects = 0;
    let totalCreditsEarned = 0;
    let inProgressSubjects = 0;

    career.semesters.forEach((semester: any) => {
      semester.subjects.forEach((subject: any) => {
        subject.enrollments.forEach((enrollment: any) => {
          totalSubjects++;

          if (enrollment.status === "COMPLETED") {
            completedSubjects++;
            totalCreditsEarned += subject.credits;
          } else if (enrollment.status === "IN_PROGRESS") {
            inProgressSubjects++;
          }
        });
      });
    });

    const progressPercentage =
      career.totalCredits > 0
        ? (totalCreditsEarned / career.totalCredits) * 100
        : 0;

    return {
      careerId: career.id,
      careerName: career.name,
      currentSemester: career.currentSemester,
      totalSemesters: career.totalSemesters,
      totalCredits: career.totalCredits,
      creditsEarned: totalCreditsEarned,
      creditsRemaining: career.totalCredits - totalCreditsEarned,
      progressPercentage: Number(progressPercentage.toFixed(2)),
      totalSubjects,
      completedSubjects,
      inProgressSubjects,
      status: career.status,
    };
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const careerService = new CareerService();
