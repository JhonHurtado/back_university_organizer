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
  sendError,
  sendErrorValidation,
  sendSuccess,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE PROFESSOR
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const data = createProfessorSchema.parse(req.body);
    const professor = await professorService.create(data);

    return sendSuccess({
      res,
      code: 201,
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

      return sendErrorValidation({ res, errors });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al crear profesor",
      error: "SERVER_ERROR",
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
    return sendError({
      res,
      code: 500,
      message: "Error al obtener profesores",
      error: "SERVER_ERROR",
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
      return sendError({
        res,
        code: 400,
        message: "Parámetro de búsqueda requerido",
        error: "MISSING_SEARCH_QUERY",
      });
    }

    const professors = await professorService.search(q);

    return sendSuccess({
      res,
      message: "Búsqueda completada exitosamente",
      data: professors,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al buscar profesores",
      error: "SERVER_ERROR",
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al obtener profesor",
      error: "SERVER_ERROR",
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar profesor",
      error: "SERVER_ERROR",
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    if (error.message === "PROFESSOR_HAS_ACTIVE_ENROLLMENTS") {
      return sendError({
        res,
        code: 400,
        message:
          "No se puede eliminar el profesor porque tiene inscripciones activas",
        error: "PROFESSOR_HAS_ACTIVE_ENROLLMENTS",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al eliminar profesor",
      error: "SERVER_ERROR",
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado o ya está activo",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al restaurar profesor",
      error: "SERVER_ERROR",
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

    return sendSuccess({
      res,
      code: 201,
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    if (error.message === "ENROLLMENT_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Inscripción no encontrada",
        error: "ENROLLMENT_NOT_FOUND",
      });
    }

    if (error.message === "PROFESSOR_ALREADY_ASSIGNED") {
      return sendError({
        res,
        code: 400,
        message: "El profesor ya está asignado a esta inscripción",
        error: "PROFESSOR_ALREADY_ASSIGNED",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al asignar profesor",
      error: "SERVER_ERROR",
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
      return sendError({
        res,
        code: 400,
        message: "enrollmentId y professorId son requeridos",
        error: "MISSING_PARAMETERS",
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
      return sendError({
        res,
        code: 404,
        message: "Asignación no encontrada",
        error: "ASSIGNMENT_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al remover profesor",
      error: "SERVER_ERROR",
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

      return sendErrorValidation({ res, errors });
    }

    if (error.message === "PROFESSOR_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Profesor no encontrado",
        error: "PROFESSOR_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al obtener materias del profesor",
      error: "SERVER_ERROR",
    });
  }
}
