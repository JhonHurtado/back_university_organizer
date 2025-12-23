// =====================================================
// controllers/professors/professor.controller.ts
// =====================================================
import type { Request, Response } from "express";
import * as professorService from "@/services/professors/professor.service";
import {
  createProfessorSchema,
  updateProfessorSchema,
  professorIdSchema,
  assignProfessorSchema,
} from "@/types/schemas/professors/professor.schemas";
import { ZodError } from "zod";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendBadRequest,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE PROFESSOR
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const data = createProfessorSchema.parse(req.body);
    const professor = await professorService.create(data);

    return sendCreated({
      res,
      message: "Profesor creado exitosamente",
      data: professor,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    return sendServerError({ res, message: "Error al crear profesor",
    });
  }
}

// =====================================================
// GET ALL PROFESSORS
// =====================================================
export async function getAll(req: Request, res: Response) {
  try {
    const { search, department, page, limit } = req.query;

    const result = await professorService.findAll({
      search: search as string,
      department: department as string,
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
    });

    return sendSuccess({
      res,
      message: "Profesores obtenidos exitosamente",
      data: {
        professors: result.professors,
        pagination: result.pagination,
      },
    });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener profesores",
    });
  }
}

// =====================================================
// SEARCH PROFESSORS
// =====================================================
export async function search(req: Request, res: Response) {
  try {
    const { q } = req.query;

    if (!q || typeof q !== "string") {
      return sendBadRequest({ res, message: "Parámetro de búsqueda requerido",
      });
    }

    const professors = await professorService.search(q);

    return sendSuccess({
      res,
      message: "Búsqueda completada exitosamente",
      data: professors,
    });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al buscar profesores",
    });
  }
}

// =====================================================
// GET PROFESSOR BY ID
// =====================================================
export async function getById(req: Request, res: Response) {
  try {
    const { id } = professorIdSchema.parse(req.params);
    const professor = await professorService.findById(id);

    return sendSuccess({
      res,
      message: "Profesor obtenido exitosamente",
      data: professor,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al obtener profesor",
    });
  }
}

// =====================================================
// UPDATE PROFESSOR
// =====================================================
export async function update(req: Request, res: Response) {
  try {
    const { id } = professorIdSchema.parse(req.params);
    const data = updateProfessorSchema.parse(req.body);

    const professor = await professorService.update(id, data);

    return sendSuccess({
      res,
      message: "Profesor actualizado exitosamente",
      data: professor,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al actualizar profesor",
    });
  }
}

// =====================================================
// SOFT DELETE PROFESSOR
// =====================================================
export async function softDelete(req: Request, res: Response) {
  try {
    const { id } = professorIdSchema.parse(req.params);
    await professorService.softDelete(id);

    return sendSuccess({
      res,
      message: "Profesor eliminado exitosamente",
      data: { id },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado",
      });
    }

    if (error.message === "PROFESSOR_HAS_ACTIVE_ENROLLMENTS") {
      return sendBadRequest({ res, message:
          "No se puede eliminar el profesor porque tiene inscripciones activas",
      });
    }

    return sendServerError({ res, message: "Error al eliminar profesor",
    });
  }
}

// =====================================================
// RESTORE PROFESSOR
// =====================================================
export async function restore(req: Request, res: Response) {
  try {
    const { id } = professorIdSchema.parse(req.params);
    const professor = await professorService.restore(id);

    return sendSuccess({
      res,
      message: "Profesor restaurado exitosamente",
      data: professor,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado o ya está activo",
      });
    }

    return sendServerError({ res, message: "Error al restaurar profesor",
    });
  }
}

// =====================================================
// ASSIGN PROFESSOR TO ENROLLMENT
// =====================================================
export async function assignToEnrollment(req: Request, res: Response) {
  try {
    const data = assignProfessorSchema.parse(req.body);
    const assignment = await professorService.assignToEnrollment(data);

    return sendCreated({
      res,
      message: "Profesor asignado exitosamente",
      data: assignment,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado",
      });
    }

    if (error.message === "ENROLLMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Inscripción no encontrada",
      });
    }

    if (error.message === "PROFESSOR_ALREADY_ASSIGNED") {
      return sendBadRequest({ res, message: "El profesor ya está asignado a esta inscripción",
      });
    }

    return sendServerError({ res, message: "Error al asignar profesor",
    });
  }
}

// =====================================================
// REMOVE PROFESSOR FROM ENROLLMENT
// =====================================================
export async function removeFromEnrollment(req: Request, res: Response) {
  try {
    const { enrollmentId, professorId } = req.body;

    if (!enrollmentId || !professorId) {
      return sendBadRequest({ res, message: "enrollmentId y professorId son requeridos",
      });
    }

    await professorService.removeFromEnrollment(enrollmentId, professorId);

    return sendSuccess({
      res,
      message: "Profesor removido de la inscripción exitosamente",
      data: { enrollmentId, professorId },
    });
  } catch (error: any) {
    if (error.message === "ASSIGNMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Asignación no encontrada",
      });
    }

    return sendServerError({ res, message: "Error al remover profesor",
    });
  }
}

// =====================================================
// GET PROFESSOR'S SUBJECTS
// =====================================================
export async function getProfessorSubjects(req: Request, res: Response) {
  try {
    const { id } = professorIdSchema.parse(req.params);
    const subjects = await professorService.getProfessorSubjects(id);

    return sendSuccess({
      res,
      message: "Materias del profesor obtenidas exitosamente",
      data: subjects,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendNotFound({ res, message: "Profesor no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al obtener materias del profesor",
    });
  }
}
