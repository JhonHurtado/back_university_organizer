// =====================================================
// controllers/careers/career.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { careerService } from "@/services/careers/career.service";
import {
  createCareerSchema,
  updateCareerSchema,
  updateSemesterSchema,
  careerIdSchema,
  careerQuerySchema,
} from "@/types/schemas/careers/career.schemas";
import { ZodError } from "zod";
import {
  sendError,
  sendErrorValidation,
  sendSuccess,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const data = createCareerSchema.parse(req.body);
    const career = await careerService.create(userId, data);

    return sendSuccess({
      res,
      code: 201,
      message: "Carrera creada exitosamente",
      data: career,
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

    if (error.message === "INVALID_SEMESTER") {
      return sendError({
        res,
        code: 400,
        message: "El semestre actual no puede exceder el total de semestres",
        error: "INVALID_SEMESTER",
      });
    }

    if (error.message === "INVALID_GRADE_RANGE") {
      return sendError({
        res,
        code: 400,
        message:
          "La nota mínima de aprobación debe ser menor que la nota máxima",
        error: "INVALID_GRADE_RANGE",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al crear carrera",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET ALL BY USER
// =====================================================
export async function getAll(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const filters = careerQuerySchema.parse(req.query);
    const result = await careerService.findByUserId(userId, filters);

    return sendSuccess({
      res,
      message: "Carreras obtenidas exitosamente",
      data: result,
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
      message: "Error al obtener carreras",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET BY ID
// =====================================================
export async function getById(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const career = await careerService.findById(id, userId);

    if (!career) {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada",
        error: "NOT_FOUND",
      });
    }

    return sendSuccess({
      res,
      message: "Carrera obtenida exitosamente",
      data: career,
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
      message: "Error al obtener carrera",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE
// =====================================================
export async function update(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const data = updateCareerSchema.parse(req.body);

    const career = await careerService.update(id, userId, data);

    return sendSuccess({
      res,
      message: "Carrera actualizada exitosamente",
      data: career,
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

    if (error.message === "NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada",
        error: "NOT_FOUND",
      });
    }

    if (error.message === "INVALID_SEMESTER") {
      return sendError({
        res,
        code: 400,
        message: "El semestre actual no puede exceder el total de semestres",
        error: "INVALID_SEMESTER",
      });
    }

    if (error.message === "INVALID_GRADE_RANGE") {
      return sendError({
        res,
        code: 400,
        message:
          "La nota mínima de aprobación debe ser menor que la nota máxima",
        error: "INVALID_GRADE_RANGE",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar carrera",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE CURRENT SEMESTER
// =====================================================
export async function updateSemester(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const { currentSemester } = updateSemesterSchema.parse(req.body);

    const career = await careerService.updateCurrentSemester(
      id,
      userId,
      currentSemester
    );

    return sendSuccess({
      res,
      message: "Semestre actual actualizado exitosamente",
      data: career,
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

    if (error.message === "NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada",
        error: "NOT_FOUND",
      });
    }

    if (error.message === "INVALID_SEMESTER") {
      return sendError({
        res,
        code: 400,
        message: "El semestre no puede exceder el total de semestres",
        error: "INVALID_SEMESTER",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar semestre",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// SOFT DELETE
// =====================================================
export async function softDelete(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    await careerService.softDelete(id, userId);

    return sendSuccess({
      res,
      message: "Carrera eliminada exitosamente",
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

    if (error.message === "NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada",
        error: "NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al eliminar carrera",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// RESTORE
// =====================================================
export async function restore(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const career = await careerService.restore(id, userId);

    return sendSuccess({
      res,
      message: "Carrera restaurada exitosamente",
      data: career,
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

    if (error.message === "NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada o no está eliminada",
        error: "NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al restaurar carrera",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET STATS
// =====================================================
export async function getStats(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendError({
        res,
        code: 401,
        message: "No autenticado",
        error: "UNAUTHORIZED",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const stats = await careerService.getCareerStats(id, userId);

    return sendSuccess({
      res,
      message: "Estadísticas obtenidas exitosamente",
      data: stats,
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

    if (error.message === "NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Carrera no encontrada",
        error: "NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al obtener estadísticas",
      error: "SERVER_ERROR",
    });
  }
}
