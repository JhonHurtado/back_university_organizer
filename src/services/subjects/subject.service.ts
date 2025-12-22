// =====================================================
// services/subjects/subject.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateSubjectInput,
  UpdateSubjectInput,
  SubjectQueryInput,
  AddPrerequisiteInput,
  AddCorequisiteInput,
} from "@/types/schemas/subjects/subject.schemas";
import type { Subject } from "generated/prisma/client";

// =====================================================
// SUBJECT SERVICE
// =====================================================
class SubjectService {
  // =====================================================
  // CREATE
  // =====================================================
  async create(userId: string, data: CreateSubjectInput): Promise<Subject> {
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

    // Verificar que el semestre existe y pertenece a la carrera
    const semester = await database.semester.findFirst({
      where: {
        id: data.semesterId,
        careerId: data.careerId,
        state: "A",
      },
    });

    if (!semester) {
      throw new Error("SEMESTER_NOT_FOUND");
    }

    // Verificar que no exista una materia con el mismo código para esta carrera
    const existingSubject = await database.subject.findUnique({
      where: {
        careerId_code: {
          careerId: data.careerId,
          code: data.code,
        },
      },
    });

    if (existingSubject) {
      throw new Error("SUBJECT_CODE_EXISTS");
    }

    const subject = await database.subject.create({
      data: {
        ...data,
        gradeWeights: data.gradeWeights as any,
      },
    });

    return subject;
  }

  // =====================================================
  // FIND BY CAREER
  // =====================================================
  async findByCareer(
    userId: string,
    careerId: string,
    filters?: SubjectQueryInput
  ): Promise<Subject[]> {
    // Verificar que la carrera existe y pertenece al usuario
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
      careerId,
      deletedAt: null,
      ...(filters?.semesterId && { semesterId: filters.semesterId }),
      ...(filters?.subjectType && { subjectType: filters.subjectType }),
      ...(filters?.isElective !== undefined && { isElective: filters.isElective }),
    };

    const subjects = await database.subject.findMany({
      where,
      orderBy: [{ semester: { number: "asc" } }, { name: "asc" }],
      include: {
        semester: true,
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
        enrollments: true,
      },
    });

    return subjects;
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(userId: string, id: string): Promise<Subject | null> {
    const subject = await database.subject.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        career: true,
        semester: true,
        prerequisites: {
          include: {
            prerequisite: {
              include: {
                semester: true,
              },
            },
          },
        },
        requiredFor: {
          include: {
            subject: {
              include: {
                semester: true,
              },
            },
          },
        },
        corequisites: {
          include: {
            corequisite: {
              include: {
                semester: true,
              },
            },
          },
        },
        corequisiteOf: {
          include: {
            subject: {
              include: {
                semester: true,
              },
            },
          },
        },
        enrollments: {
          include: {
            academicPeriod: true,
          },
        },
      },
    });

    if (!subject) {
      return null;
    }

    // Verificar que la carrera pertenece al usuario
    if (subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    return subject;
  }

  // =====================================================
  // UPDATE
  // =====================================================
  async update(
    userId: string,
    id: string,
    data: UpdateSubjectInput
  ): Promise<Subject> {
    // Verificar que la materia existe y pertenece al usuario
    const subject = await database.subject.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject) {
      throw new Error("NOT_FOUND");
    }

    if (subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Si se actualiza el código, verificar que no exista
    if (data.code && data.code !== subject.code) {
      const existingSubject = await database.subject.findUnique({
        where: {
          careerId_code: {
            careerId: subject.careerId,
            code: data.code,
          },
        },
      });

      if (existingSubject) {
        throw new Error("SUBJECT_CODE_EXISTS");
      }
    }

    const updatedSubject = await database.subject.update({
      where: { id },
      data: {
        ...data,
        gradeWeights: data.gradeWeights !== undefined ? (data.gradeWeights as any) : undefined,
      },
    });

    return updatedSubject;
  }

  // =====================================================
  // SOFT DELETE
  // =====================================================
  async softDelete(userId: string, id: string): Promise<void> {
    // Verificar que la materia existe y pertenece al usuario
    const subject = await database.subject.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject) {
      throw new Error("NOT_FOUND");
    }

    if (subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.subject.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        state: "I",
      },
    });
  }

  // =====================================================
  // ADD PREREQUISITE
  // =====================================================
  async addPrerequisite(
    userId: string,
    subjectId: string,
    data: AddPrerequisiteInput
  ) {
    // Verificar que ambas materias existen y pertenecen al usuario
    const subject = await database.subject.findFirst({
      where: {
        id: subjectId,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject || subject.career.userId !== userId) {
      throw new Error("SUBJECT_NOT_FOUND");
    }

    const prerequisite = await database.subject.findFirst({
      where: {
        id: data.prerequisiteId,
        careerId: subject.careerId,
        deletedAt: null,
      },
    });

    if (!prerequisite) {
      throw new Error("PREREQUISITE_NOT_FOUND");
    }

    // Evitar agregar la misma materia como prerequisito
    if (subjectId === data.prerequisiteId) {
      throw new Error("CANNOT_BE_SELF_PREREQUISITE");
    }

    // Verificar que no exista ya
    const existing = await database.subjectPrerequisite.findUnique({
      where: {
        subjectId_prerequisiteId: {
          subjectId,
          prerequisiteId: data.prerequisiteId,
        },
      },
    });

    if (existing) {
      throw new Error("PREREQUISITE_ALREADY_EXISTS");
    }

    const result = await database.subjectPrerequisite.create({
      data: {
        subjectId,
        prerequisiteId: data.prerequisiteId,
        isStrict: data.isStrict,
      },
      include: {
        prerequisite: true,
      },
    });

    return result;
  }

  // =====================================================
  // REMOVE PREREQUISITE
  // =====================================================
  async removePrerequisite(
    userId: string,
    subjectId: string,
    prerequisiteId: string
  ) {
    // Verificar que la materia pertenece al usuario
    const subject = await database.subject.findFirst({
      where: {
        id: subjectId,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject || subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.subjectPrerequisite.delete({
      where: {
        subjectId_prerequisiteId: {
          subjectId,
          prerequisiteId,
        },
      },
    });
  }

  // =====================================================
  // ADD COREQUISITE
  // =====================================================
  async addCorequisite(
    userId: string,
    subjectId: string,
    data: AddCorequisiteInput
  ) {
    // Verificar que ambas materias existen y pertenecen al usuario
    const subject = await database.subject.findFirst({
      where: {
        id: subjectId,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject || subject.career.userId !== userId) {
      throw new Error("SUBJECT_NOT_FOUND");
    }

    const corequisite = await database.subject.findFirst({
      where: {
        id: data.corequisiteId,
        careerId: subject.careerId,
        deletedAt: null,
      },
    });

    if (!corequisite) {
      throw new Error("COREQUISITE_NOT_FOUND");
    }

    // Evitar agregar la misma materia como corequisito
    if (subjectId === data.corequisiteId) {
      throw new Error("CANNOT_BE_SELF_COREQUISITE");
    }

    // Verificar que no exista ya
    const existing = await database.subjectCorequisite.findUnique({
      where: {
        subjectId_corequisiteId: {
          subjectId,
          corequisiteId: data.corequisiteId,
        },
      },
    });

    if (existing) {
      throw new Error("COREQUISITE_ALREADY_EXISTS");
    }

    const result = await database.subjectCorequisite.create({
      data: {
        subjectId,
        corequisiteId: data.corequisiteId,
      },
      include: {
        corequisite: true,
      },
    });

    return result;
  }

  // =====================================================
  // REMOVE COREQUISITE
  // =====================================================
  async removeCorequisite(
    userId: string,
    subjectId: string,
    corequisiteId: string
  ) {
    // Verificar que la materia pertenece al usuario
    const subject = await database.subject.findFirst({
      where: {
        id: subjectId,
        deletedAt: null,
      },
      include: {
        career: true,
      },
    });

    if (!subject || subject.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    await database.subjectCorequisite.delete({
      where: {
        subjectId_corequisiteId: {
          subjectId,
          corequisiteId,
        },
      },
    });
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const subjectService = new SubjectService();
