// =====================================================
// services/enrollments/enrollment.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateEnrollmentInput,
  UpdateEnrollmentInput,
  EnrollmentQueryInput,
} from "@/types/schemas/enrollments/enrollment.schemas";
import type { SubjectEnrollment } from "generated/prisma/client";

// =====================================================
// ENROLLMENT SERVICE
// =====================================================
class EnrollmentService {
  // =====================================================
  // CREATE (ENROLL IN SUBJECT)
  // =====================================================
  async create(userId: string, data: CreateEnrollmentInput): Promise<SubjectEnrollment> {
    // Verificar que la materia existe
    const subject = await database.subject.findFirst({
      where: {
        id: data.subjectId,
        deletedAt: null,
      },
      include: {
        career: true,
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
      },
    });

    if (!subject) {
      throw new Error("SUBJECT_NOT_FOUND");
    }

    // Verificar que la carrera pertenece al usuario
    if (subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Verificar que el período académico existe y pertenece a la carrera
    const academicPeriod = await database.academicPeriod.findFirst({
      where: {
        id: data.academicPeriodId,
        careerId: subject.careerId,
        state: "A",
      },
    });

    if (!academicPeriod) {
      throw new Error("ACADEMIC_PERIOD_NOT_FOUND");
    }

    // Verificar que no exista una inscripción activa para esta materia en este período
    const existingEnrollment = await database.subjectEnrollment.findUnique({
      where: {
        subjectId_academicPeriodId_attempt: {
          subjectId: data.subjectId,
          academicPeriodId: data.academicPeriodId,
          attempt: data.attempt || 1,
        },
      },
    });

    if (existingEnrollment) {
      throw new Error("ALREADY_ENROLLED");
    }

    // Validar prerequisites (solo los estrictos)
    const strictPrerequisites = subject.prerequisites.filter((p) => p.isStrict);
    if (strictPrerequisites.length > 0) {
      const prerequisiteIds = strictPrerequisites.map((p) => p.prerequisiteId);

      // Buscar inscripciones aprobadas de los prerequisitos
      const passedPrerequisites = await database.subjectEnrollment.findMany({
        where: {
          subjectId: { in: prerequisiteIds },
          subject: {
            careerId: subject.careerId,
          },
          status: "PASSED",
        },
        select: {
          subjectId: true,
        },
      });

      const passedIds = passedPrerequisites.map((e) => e.subjectId);
      const missingPrerequisites = prerequisiteIds.filter((id) => !passedIds.includes(id));

      if (missingPrerequisites.length > 0) {
        throw new Error("PREREQUISITES_NOT_MET");
      }
    }

    // Validar corequisites (deben estar inscritos en el mismo período o ya aprobados)
    if (subject.corequisites.length > 0) {
      const corequisiteIds = subject.corequisites.map((c) => c.corequisiteId);

      const corequisiteEnrollments = await database.subjectEnrollment.findMany({
        where: {
          OR: [
            {
              subjectId: { in: corequisiteIds },
              academicPeriodId: data.academicPeriodId,
            },
            {
              subjectId: { in: corequisiteIds },
              status: "PASSED",
            },
          ],
        },
        select: {
          subjectId: true,
        },
      });

      const enrolledOrPassedIds = corequisiteEnrollments.map((e) => e.subjectId);
      const missingCorequisites = corequisiteIds.filter((id) => !enrolledOrPassedIds.includes(id));

      if (missingCorequisites.length > 0) {
        throw new Error("COREQUISITES_NOT_MET");
      }
    }

    const enrollment = await database.subjectEnrollment.create({
      data,
      include: {
        subject: {
          include: {
            semester: true,
          },
        },
        academicPeriod: true,
      },
    });

    return enrollment;
  }

  // =====================================================
  // FIND BY USER
  // =====================================================
  async findByUser(
    userId: string,
    careerId: string,
    filters?: EnrollmentQueryInput
  ): Promise<SubjectEnrollment[]> {
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

    const where: any = {
      subject: {
        careerId,
      },
      ...(filters?.subjectId && { subjectId: filters.subjectId }),
      ...(filters?.academicPeriodId && { academicPeriodId: filters.academicPeriodId }),
      ...(filters?.status && { status: filters.status }),
    };

    const enrollments = await database.subjectEnrollment.findMany({
      where,
      orderBy: [{ academicPeriod: { year: "desc" } }, { academicPeriod: { period: "desc" } }],
      include: {
        subject: {
          include: {
            semester: true,
          },
        },
        academicPeriod: true,
        grades: true,
      },
    });

    return enrollments;
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(userId: string, id: string): Promise<SubjectEnrollment | null> {
    const enrollment = await database.subjectEnrollment.findFirst({
      where: {
        id,
      },
      include: {
        subject: {
          include: {
            career: true,
            semester: true,
          },
        },
        academicPeriod: true,
        grades: {
          include: {
            gradeItems: true,
          },
        },
        schedules: true,
        professors: {
          include: {
            professor: true,
          },
        },
      },
    });

    if (!enrollment) {
      return null;
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    return enrollment;
  }

  // =====================================================
  // UPDATE
  // =====================================================
  async update(
    userId: string,
    id: string,
    data: UpdateEnrollmentInput
  ): Promise<SubjectEnrollment> {
    const enrollment = await database.subjectEnrollment.findFirst({
      where: {
        id,
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
      throw new Error("NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Actualizar fechas automáticamente según el estado
    const updateData: any = { ...data };

    if (data.status === "WITHDRAWN" && !data.withdrawnAt) {
      updateData.withdrawnAt = new Date();
    }

    if (data.status === "COMPLETED" && !data.completedAt) {
      updateData.completedAt = new Date();
    }

    const updated = await database.subjectEnrollment.update({
      where: { id },
      data: updateData,
    });

    return updated;
  }

  // =====================================================
  // DELETE (WITHDRAW)
  // =====================================================
  async withdraw(userId: string, id: string): Promise<SubjectEnrollment> {
    const enrollment = await database.subjectEnrollment.findFirst({
      where: {
        id,
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
      throw new Error("NOT_FOUND");
    }

    if (enrollment.subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // No se puede retirar si ya está completada o aprobada
    if (["COMPLETED", "PASSED"].includes(enrollment.status)) {
      throw new Error("CANNOT_WITHDRAW_COMPLETED");
    }

    const updated = await database.subjectEnrollment.update({
      where: { id },
      data: {
        status: "WITHDRAWN",
        withdrawnAt: new Date(),
      },
    });

    return updated;
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const enrollmentService = new EnrollmentService();
