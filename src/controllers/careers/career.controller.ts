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
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendBadRequest,
  sendServerError,
  sendValidationError,
  sendUnauthorized,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendUnauthorized({
        res,
        message: "No autenticado",
      });
    }
    const data = createCareerSchema.parse(req.body);
    const career = await careerService.create(userId, data);

    return sendCreated({
      res,
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "INVALID_SEMESTER") {
      return sendBadRequest({
        res,
        message: "El semestre actual no puede exceder el total de semestres",
      });
    }

    if (error.message === "INVALID_GRADE_RANGE") {
      return sendBadRequest({
        res,
        message:
          "La nota mínima de aprobación debe ser menor que la nota máxima",
      });
    }

    return sendServerError({
      res,
      message: "Error al crear carrera",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({
      res,
      message: "Error al obtener carreras",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
      });
    }

    const { id } = careerIdSchema.parse(req.params);
    const career = await careerService.findById(id, userId);

    if (!career) {
      return sendNotFound({
        res,
        message: "Carrera no encontrada",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({
      res,
      message: "Error al obtener carrera",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "NOT_FOUND") {
      return sendNotFound({
        res,
        message: "Carrera no encontrada",
      });
    }

    if (error.message === "INVALID_SEMESTER") {
      return sendBadRequest({
        res,
        message: "El semestre actual no puede exceder el total de semestres",
      });
    }

    if (error.message === "INVALID_GRADE_RANGE") {
      return sendBadRequest({
        res,
        message:
          "La nota mínima de aprobación debe ser menor que la nota máxima",
      });
    }

    return sendServerError({
      res,
      message: "Error al actualizar carrera",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "NOT_FOUND") {
      return sendNotFound({
        res,
        message: "Carrera no encontrada",
      });
    }

    if (error.message === "INVALID_SEMESTER") {
      return sendBadRequest({
        res,
        message: "El semestre no puede exceder el total de semestres",
      });
    }

    return sendServerError({
      res,
      message: "Error al actualizar semestre",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "NOT_FOUND") {
      return sendNotFound({
        res,
        message: "Carrera no encontrada",
      });
    }

    return sendServerError({
      res,
      message: "Error al eliminar carrera",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "NOT_FOUND") {
      return sendNotFound({
        res,
        message: "Carrera no encontrada o no está eliminada",
      });
    }

    return sendServerError({
      res,
      message: "Error al restaurar carrera",
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
      return sendUnauthorized({
        res,
        message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "NOT_FOUND") {
      return sendNotFound({
        res,
        message: "Carrera no encontrada",
      });
    }

    return sendServerError({
      res,
      message: "Error al obtener estadísticas",
    });
  }
}
