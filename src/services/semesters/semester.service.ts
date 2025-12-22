// =====================================================
// services/semesters/semester.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateSemesterInput,
  UpdateSemesterInput,
} from "@/types/schemas/semesters/semester.schemas";
import type { Semester } from "@prisma/client";

// =====================================================
// SEMESTER SERVICE
// =====================================================
class SemesterService {
  // =====================================================
  // CREATE
  // =====================================================
  async create(userId: string, data: CreateSemesterInput): Promise<Semester> {
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

    // Verificar que el número de semestre no exceda el total de semestres de la carrera
    if (data.number > career.totalSemesters) {
      throw new Error("INVALID_SEMESTER_NUMBER");
    }

    // Verificar que no exista un semestre con el mismo número para esta carrera
    const existingSemester = await database.semester.findUnique({
      where: {
        careerId_number: {
          careerId: data.careerId,
          number: data.number,
        },
      },
    });

    if (existingSemester) {
      throw new Error("SEMESTER_ALREADY_EXISTS");
    }

    // Validar coherencia de créditos
    if (data.minCredits && data.maxCredits && data.minCredits > data.maxCredits) {
      throw new Error("INVALID_CREDIT_RANGE");
    }

    const semester = await database.semester.create({
      data,
    });

    return semester;
  }

  // =====================================================
  // FIND BY CAREER
  // =====================================================
  async findByCareer(userId: string, careerId: string): Promise<Semester[]> {
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

    const semesters = await database.semester.findMany({
      where: {
        careerId,
        state: "A",
      },
      orderBy: {
        number: "asc",
      },
      include: {
        subjects: {
          where: {
            deletedAt: null,
          },
          orderBy: {
            name: "asc",
          },
        },
      },
    });

    return semesters;
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(userId: string, id: string): Promise<Semester | null> {
    const semester = await database.semester.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
        subjects: {
          where: {
            deletedAt: null,
          },
          orderBy: {
            name: "asc",
          },
        },
      },
    });

    if (!semester) {
      return null;
    }

    // Verificar que la carrera pertenece al usuario
    if (semester.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    return semester;
  }

  // =====================================================
  // UPDATE
  // =====================================================
  async update(
    userId: string,
    id: string,
    data: UpdateSemesterInput
  ): Promise<Semester> {
    // Verificar que el semestre existe y pertenece al usuario
    const semester = await database.semester.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
      },
    });

    if (!semester) {
      throw new Error("NOT_FOUND");
    }

    if (semester.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Si se actualiza el número, validar
    if (data.number) {
      if (data.number > semester.career.totalSemesters) {
        throw new Error("INVALID_SEMESTER_NUMBER");
      }

      // Verificar que no exista otro semestre con ese número
      const existingSemester = await database.semester.findUnique({
        where: {
          careerId_number: {
            careerId: semester.careerId,
            number: data.number,
          },
        },
      });

      if (existingSemester && existingSemester.id !== id) {
        throw new Error("SEMESTER_ALREADY_EXISTS");
      }
    }

    // Validar coherencia de créditos
    const minCredits = data.minCredits ?? semester.minCredits;
    const maxCredits = data.maxCredits ?? semester.maxCredits;
    if (minCredits && maxCredits && minCredits > maxCredits) {
      throw new Error("INVALID_CREDIT_RANGE");
    }

    const updatedSemester = await database.semester.update({
      where: { id },
      data,
    });

    return updatedSemester;
  }

  // =====================================================
  // DELETE
  // =====================================================
  async delete(userId: string, id: string): Promise<void> {
    // Verificar que el semestre existe y pertenece al usuario
    const semester = await database.semester.findFirst({
      where: {
        id,
        state: "A",
      },
      include: {
        career: true,
        subjects: true,
      },
    });

    if (!semester) {
      throw new Error("NOT_FOUND");
    }

    if (semester.career.userId !== userId) {
      throw new Error("UNAUTHORIZED");
    }

    // Verificar que no tenga materias
    if (semester.subjects.length > 0) {
      throw new Error("SEMESTER_HAS_SUBJECTS");
    }

    await database.semester.update({
      where: { id },
      data: { state: "I" },
    });
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const semesterService = new SemesterService();
