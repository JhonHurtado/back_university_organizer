// =====================================================
// controllers/users/user.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { userService } from "@/services/users/users.service";
import {
  createUserSchema,
  updateUserSchema,
  userIdSchema,
  updatePasswordSchema,
} from "@/types/schemas/users/user.schemas";
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
    const data = createUserSchema.parse(req.body);
    const user = await userService.create(data);

    return sendSuccess({
      res,
      code: 201,
      message: "Usuario creado exitosamente",
      data: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        timezone: user.timezone,
        language: user.language,
        isActive: user.isActive,
        createdAt: user.createdAt,
      },
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

    if (error.message === "EMAIL_EXISTS") {
      return sendError({
        res,
        code: 409,
        message: "El email ya está registrado",
        error: "EMAIL_EXISTS",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al crear usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET ALL
// =====================================================
export async function getAll(req: Request, res: Response) {
  try {
    const { page, limit, isActive, search } = req.query;

    const result = await userService.findAll({
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      isActive: isActive ? isActive === "true" : undefined,
      search: search as string,
    });

    return sendSuccess({
      res,
      message: "Usuarios obtenidos exitosamente",
      data: result,
    });
  } catch (error) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener usuarios",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET BY ID
// =====================================================
export async function getById(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    const user = await userService.findById(id);

    if (!user) {
      return sendError({
        res,
        code: 404,
        message: "Usuario no encontrado",
        error: "NOT_FOUND",
      });
    }

    return sendSuccess({
      res,
      message: "Usuario obtenido exitosamente",
      data: user,
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
      message: "Error al obtener usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE
// =====================================================
export async function update(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    const data = updateUserSchema.parse(req.body);

    const user = await userService.update(id, data);

    return sendSuccess({
      res,
      message: "Usuario actualizado exitosamente",
      data: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        avatar: user.avatar,
        timezone: user.timezone,
        language: user.language,
        updatedAt: user.updatedAt,
      },
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

    if (error.message === "EMAIL_EXISTS") {
      return sendError({
        res,
        code: 409,
        message: "El email ya está registrado",
        error: "EMAIL_EXISTS",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE PASSWORD
// =====================================================
export async function updatePassword(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    const { password } = updatePasswordSchema.parse(req.body);

    await userService.updatePassword(id, password);

    return sendSuccess({
      res,
      message: "Contraseña actualizada exitosamente",
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
      message: "Error al actualizar contraseña",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// ACTIVATE
// =====================================================
export async function activate(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    await userService.activate(id);

    return sendSuccess({
      res,
      message: "Usuario activado exitosamente",
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
      message: "Error al activar usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// DEACTIVATE
// =====================================================
export async function deactivate(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    await userService.deactivate(id);

    return sendSuccess({
      res,
      message: "Usuario desactivado exitosamente",
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
      message: "Error al desactivar usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// SOFT DELETE
// =====================================================
export async function softDelete(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    await userService.softDelete(id);

    return sendSuccess({
      res,
      message: "Usuario eliminado exitosamente",
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
      message: "Error al eliminar usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// RESTORE
// =====================================================
export async function restore(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    await userService.restore(id);

    return sendSuccess({
      res,
      message: "Usuario restaurado exitosamente",
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
      message: "Error al restaurar usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET STATS
// =====================================================
export async function getStats(req: Request, res: Response) {
  try {
    const { id } = userIdSchema.parse(req.params);
    const stats = await userService.getUserStats(id);

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

    return sendError({
      res,
      code: 500,
      message: "Error al obtener estadísticas",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// SEARCH
// =====================================================
export async function search(req: Request, res: Response) {
  try {
    const { q, limit } = req.query;

    if (!q) {
      return sendError({
        res,
        code: 400,
        message: "El parámetro 'q' es requerido",
        error: "MISSING_QUERY",
      });
    }

    const users = await userService.search(
      q as string,
      limit ? parseInt(limit as string) : undefined
    );

    return sendSuccess({
      res,
      message: "Búsqueda realizada exitosamente",
      data: users,
    });
  } catch (error) {
    return sendError({
      res,
      code: 500,
      message: "Error en la búsqueda",
      error: "SERVER_ERROR",
    });
  }
}