// =====================================================
// services/academicPeriods/academicPeriod.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateAcademicPeriodInput,
  UpdateAcademicPeriodInput,
} from "@/types/schemas/academicPeriods/academicPeriod.schemas";
import type { AcademicPeriod } from "@prisma/client";

// =====================================================
// ACADEMIC PERIOD SERVICE
// =====================================================
class AcademicPeriodService {
  // =====================================================
  // CREATE
  // =====================================================
  async create(userId: string, data: CreateAcademicPeriodInput): Promise<AcademicPeriod> {
    // Verificar que la carrera existe y pertenece al usuario
    const career = await database.career.findFirst({
      where: {
        id: data.careerId,
        userId,
        deletedAt: null,
      },
    });

    if (!career) {
      throw new Error("CAREER_NOT_FOUND");
    }

    // Validar fechas
    if (data.startDate >= data.endDate) {
      throw new Error("INVALID_DATE_RANGE");
    }

    // Verificar que no exista un período con el mismo año y período
    const existing = await database.academicPeriod.findUnique({
      where: {
        careerId_year_period: {
          careerId: data.careerId,
          year: data.year,
          period: data.period,
        },
      },
    });

    if (existing) {
      throw new Error("ACADEMIC_PERIOD_EXISTS");
    }

    // Si isCurrent es true, desmarcar otros períodos actuales
    if (data.isCurrent) {
      await database.academicPeriod.updateMany({
        where: {
          careerId: data.careerId,
          isCurrent: true,
        },
        data: {
          isCurrent: false,
        },
      });
    }

    const academicPeriod = await database.academicPeriod.create({
      data,
    });

    return academicPeriod;
  }

  // =====================================================
  // FIND BY CAREER
  // =====================================================
  async findByCareer(userId: string, careerId: string): Promise<AcademicPeriod[]> {
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

    const periods = await database.academicPeriod.findMany({
      where: {
        careerId,
        state: "A",
      },
      orderBy: [{ year: "desc" }, { period: "desc" }],
    });

    return periods;
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(userId: string, id: string): Promise<AcademicPeriod | null> {
    const period = await database.academicPeriod.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
      },
    });

    if (!period) {
      return null;
    }

    if (period.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    return period;
  }

  // =====================================================
  // UPDATE
  // =====================================================
  async update(
    userId: string,
    id: string,
    data: UpdateAcademicPeriodInput
  ): Promise<AcademicPeriod> {
    const period = await database.academicPeriod.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
      },
    });

    if (!period) {
      throw new Error("NOT_FOUND");
    }

    if (period.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Validar fechas si se actualizan
    const startDate = data.startDate || period.startDate;
    const endDate = data.endDate || period.endDate;
    if (startDate >= endDate) {
      throw new Error("INVALID_DATE_RANGE");
    }

    // Si isCurrent es true, desmarcar otros períodos actuales
    if (data.isCurrent) {
      await database.academicPeriod.updateMany({
        where: {
          careerId: period.careerId,
          isCurrent: true,
          id: { not: id },
        },
        data: {
          isCurrent: false,
        },
      });
    }

    const updated = await database.academicPeriod.update({
      where: { id },
      data,
    });

    return updated;
  }

  // =====================================================
  // DELETE
  // =====================================================
  async delete(userId: string, id: string): Promise<void> {
    const period = await database.academicPeriod.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
        subjectEnrollments: true,
      },
    });

    if (!period) {
      throw new Error("NOT_FOUND");
    }

    if (period.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Verificar que no tenga inscripciones
    if (period.subjectEnrollments.length > 0) {
      throw new Error("PERIOD_HAS_ENROLLMENTS");
    }

    await database.academicPeriod.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // GET CURRENT PERIOD
  // =====================================================
  async getCurrentPeriod(userId: string, careerId: string): Promise<AcademicPeriod | null> {
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

    const period = await database.academicPeriod.findFirst({
      where: {
        careerId,
        isCurrent: true,
        state: "A",
      },
    });

    return period;
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const academicPeriodService = new AcademicPeriodService();
