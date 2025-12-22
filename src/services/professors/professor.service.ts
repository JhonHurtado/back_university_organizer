// =====================================================
// services/professors/professor.service.ts
// =====================================================

import database from "@/lib/prisma/prisma";
import type {
  CreateProfessorInput,
  UpdateProfessorInput,
  SearchProfessorsInput,
  AssignProfessorInput,
} from "@/types/schemas/professors/professor.schemas";

// =====================================================
// CREATE PROFESSOR
// =====================================================
export async function create(data: CreateProfessorInput) {
  return database.professor.create({
    data: {
      ...data,
      state: "A",
    },
  });
}

// =====================================================
// FIND ALL PROFESSORS (with pagination and filters)
// =====================================================
export async function findAll(params?: SearchProfessorsInput) {
  const { search, department, page = 1, limit = 20 } = params || {};

  const where: any = {
    state: "A",
  };

  // Search by name or email
  if (search) {
    where.OR = [
      { firstName: { contains: search, mode: "insensitive" } },
      { lastName: { contains: search, mode: "insensitive" } },
      { email: { contains: search, mode: "insensitive" } },
    ];
  }

  // Filter by department
  if (department) {
    where.department = { contains: department, mode: "insensitive" };
  }

  const [professors, total] = await Promise.all([
    database.professor.findMany({
      where,
      orderBy: [{ lastName: "asc" }, { firstName: "asc" }],
      skip: (page - 1) * limit,
      take: limit,
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        office: true,
        department: true,
        title: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: {
            enrollments: true,
          },
        },
      },
    }),
    database.professor.count({ where }),
  ]);

  return {
    professors,
    pagination: {
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    },
  };
}

// =====================================================
// FIND BY ID
// =====================================================
export async function findById(id: string) {
  const professor = await database.professor.findFirst({
    where: { id, state: "A" },
    include: {
      enrollments: {
        include: {
          enrollment: {
            include: {
              subject: {
                select: {
                  id: true,
                  code: true,
                  name: true,
                  credits: true,
                },
              },
              academicPeriod: {
                select: {
                  id: true,
                  name: true,
                  year: true,
                  period: true,
                  isCurrent: true,
                },
              },
            },
          },
        },
      },
    },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  return professor;
}

// =====================================================
// UPDATE PROFESSOR
// =====================================================
export async function update(id: string, data: UpdateProfessorInput) {
  const professor = await database.professor.findFirst({
    where: { id, state: "A" },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  return database.professor.update({
    where: { id },
    data,
  });
}

// =====================================================
// SOFT DELETE PROFESSOR
// =====================================================
export async function softDelete(id: string) {
  const professor = await database.professor.findFirst({
    where: { id, state: "A" },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  // Check if professor has active enrollments
  const activeEnrollments = await database.enrollmentProfessor.count({
    where: {
      professorId: id,
      state: "A",
    },
  });

  if (activeEnrollments > 0) {
    throw new Error("PROFESSOR_HAS_ACTIVE_ENROLLMENTS");
  }

  return database.professor.update({
    where: { id },
    data: { state: "I" },
  });
}

// =====================================================
// RESTORE PROFESSOR
// =====================================================
export async function restore(id: string) {
  const professor = await database.professor.findFirst({
    where: { id, state: "I" },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  return database.professor.update({
    where: { id },
    data: { state: "A" },
  });
}

// =====================================================
// ASSIGN PROFESSOR TO ENROLLMENT
// =====================================================
export async function assignToEnrollment(data: AssignProfessorInput) {
  const { enrollmentId, professorId, role } = data;

  // Verify professor exists
  const professor = await database.professor.findFirst({
    where: { id: professorId, state: "A" },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  // Verify enrollment exists
  const enrollment = await database.subjectEnrollment.findFirst({
    where: { id: enrollmentId, state: "A" },
  });

  if (!enrollment) {
    throw new Error("ENROLLMENT_NOT_FOUND");
  }

  // Check if already assigned
  const existing = await database.enrollmentProfessor.findFirst({
    where: {
      enrollmentId,
      professorId,
      state: "A",
    },
  });

  if (existing) {
    throw new Error("PROFESSOR_ALREADY_ASSIGNED");
  }

  return database.enrollmentProfessor.create({
    data: {
      enrollmentId,
      professorId,
      role: role || "main",
      state: "A",
    },
    include: {
      professor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          email: true,
          office: true,
          title: true,
        },
      },
      enrollment: {
        select: {
          id: true,
          subject: {
            select: {
              code: true,
              name: true,
            },
          },
        },
      },
    },
  });
}

// =====================================================
// REMOVE PROFESSOR FROM ENROLLMENT
// =====================================================
export async function removeFromEnrollment(
  enrollmentId: string,
  professorId: string
) {
  const assignment = await database.enrollmentProfessor.findFirst({
    where: {
      enrollmentId,
      professorId,
      state: "A",
    },
  });

  if (!assignment) {
    throw new Error("ASSIGNMENT_NOT_FOUND");
  }

  return database.enrollmentProfessor.update({
    where: { id: assignment.id },
    data: { state: "I" },
  });
}

// =====================================================
// GET PROFESSOR'S SUBJECTS
// =====================================================
export async function getProfessorSubjects(professorId: string) {
  const professor = await database.professor.findFirst({
    where: { id: professorId, state: "A" },
  });

  if (!professor) {
    throw new Error("PROFESSOR_NOT_FOUND");
  }

  const enrollments = await database.enrollmentProfessor.findMany({
    where: {
      professorId,
      state: "A",
    },
    include: {
      enrollment: {
        include: {
          subject: {
            select: {
              id: true,
              code: true,
              name: true,
              credits: true,
              hoursPerWeek: true,
            },
          },
          academicPeriod: {
            select: {
              id: true,
              name: true,
              year: true,
              period: true,
              isCurrent: true,
            },
          },
        },
      },
    },
    orderBy: {
      enrollment: {
        academicPeriod: {
          startDate: "desc",
        },
      },
    },
  });

  return enrollments.map((e) => ({
    enrollmentId: e.enrollmentId,
    role: e.role,
    subject: e.enrollment.subject,
    academicPeriod: e.enrollment.academicPeriod,
    section: e.enrollment.section,
    status: e.enrollment.status,
  }));
}

// =====================================================
// SEARCH PROFESSORS (simple search)
// =====================================================
export async function search(query: string) {
  return database.professor.findMany({
    where: {
      state: "A",
      OR: [
        { firstName: { contains: query, mode: "insensitive" } },
        { lastName: { contains: query, mode: "insensitive" } },
        { email: { contains: query, mode: "insensitive" } },
        { department: { contains: query, mode: "insensitive" } },
      ],
    },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      department: true,
      title: true,
      office: true,
    },
    orderBy: [{ lastName: "asc" }, { firstName: "asc" }],
    take: 20,
  });
}
