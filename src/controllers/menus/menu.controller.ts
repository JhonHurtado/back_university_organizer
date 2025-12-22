// =====================================================
// controllers/menus/menu.controller.ts
// =====================================================
import type { Request, Response } from "express";
import * as menuService from "@/services/menus/menu.service";
import {
  createMenuSchema,
  updateMenuSchema,
  menuIdSchema,
  planMenuAccessSchema,
  updatePlanMenuAccessSchema,
} from "@/types/schemas/menus/menu.schemas";
import { ZodError } from "zod";
import {
  sendError,
  sendErrorValidation,
  sendSuccess,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE MENU
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const data = createMenuSchema.parse(req.body);
    const menu = await menuService.create(data);

    return sendSuccess({
      res,
      code: 201,
      message: "Menú creado exitosamente",
      data: menu,
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

    if (error.message === "PARENT_MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú padre no encontrado",
        error: "PARENT_MENU_NOT_FOUND",
      });
    }

    if (error.message === "MENU_NAME_EXISTS") {
      return sendError({
        res,
        code: 409,
        message: "Ya existe un menú con ese nombre",
        error: "MENU_NAME_EXISTS",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al crear menú",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET ALL MENUS (flat list)
// =====================================================
export async function getAll(_req: Request, res: Response) {
  try {
    const menus = await menuService.findAll();

    return sendSuccess({
      res,
      message: "Menús obtenidos exitosamente",
      data: menus,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener menús",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET MENU TREE
// =====================================================
export async function getMenuTree(_req: Request, res: Response) {
  try {
    const menuTree = await menuService.getMenuTree();

    return sendSuccess({
      res,
      message: "Árbol de menús obtenido exitosamente",
      data: menuTree,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener árbol de menús",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET MENU TREE BY USER (with plan permissions)
// =====================================================
export async function getMenuTreeByUser(req: Request, res: Response) {
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

    const menuTree = await menuService.getMenuTreeByUser(userId);

    return sendSuccess({
      res,
      message: "Menú del usuario obtenido exitosamente",
      data: menuTree,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener menú del usuario",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET MENU BY ID
// =====================================================
export async function getById(req: Request, res: Response) {
  try {
    const { id } = menuIdSchema.parse(req.params);
    const menu = await menuService.findById(id);

    return sendSuccess({
      res,
      message: "Menú obtenido exitosamente",
      data: menu,
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

    if (error.message === "MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú no encontrado",
        error: "MENU_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al obtener menú",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE MENU
// =====================================================
export async function update(req: Request, res: Response) {
  try {
    const { id } = menuIdSchema.parse(req.params);
    const data = updateMenuSchema.parse(req.body);

    const menu = await menuService.update(id, data);

    return sendSuccess({
      res,
      message: "Menú actualizado exitosamente",
      data: menu,
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

    if (error.message === "MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú no encontrado",
        error: "MENU_NOT_FOUND",
      });
    }

    if (error.message === "PARENT_MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú padre no encontrado",
        error: "PARENT_MENU_NOT_FOUND",
      });
    }

    if (error.message === "CIRCULAR_REFERENCE") {
      return sendError({
        res,
        code: 400,
        message: "No se puede asignar el menú como su propio padre",
        error: "CIRCULAR_REFERENCE",
      });
    }

    if (error.message === "MENU_NAME_EXISTS") {
      return sendError({
        res,
        code: 409,
        message: "Ya existe un menú con ese nombre",
        error: "MENU_NAME_EXISTS",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar menú",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// SOFT DELETE MENU
// =====================================================
export async function softDelete(req: Request, res: Response) {
  try {
    const { id } = menuIdSchema.parse(req.params);
    await menuService.softDelete(id);

    return sendSuccess({
      res,
      message: "Menú eliminado exitosamente",
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

    if (error.message === "MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú no encontrado",
        error: "MENU_NOT_FOUND",
      });
    }

    if (error.message === "MENU_HAS_CHILDREN") {
      return sendError({
        res,
        code: 400,
        message: "No se puede eliminar un menú que tiene submenús",
        error: "MENU_HAS_CHILDREN",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al eliminar menú",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// RESTORE MENU
// =====================================================
export async function restore(req: Request, res: Response) {
  try {
    const { id } = menuIdSchema.parse(req.params);
    const menu = await menuService.restore(id);

    return sendSuccess({
      res,
      message: "Menú restaurado exitosamente",
      data: menu,
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

    if (error.message === "MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú no encontrado o ya está activo",
        error: "MENU_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al restaurar menú",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// ASSIGN PLAN ACCESS TO MENU
// =====================================================
export async function assignPlanAccess(req: Request, res: Response) {
  try {
    const data = planMenuAccessSchema.parse(req.body);
    const access = await menuService.assignPlanAccess(data);

    return sendSuccess({
      res,
      code: 201,
      message: "Acceso de plan asignado exitosamente",
      data: access,
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

    if (error.message === "MENU_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Menú no encontrado",
        error: "MENU_NOT_FOUND",
      });
    }

    if (error.message === "PLAN_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Plan no encontrado",
        error: "PLAN_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al asignar acceso",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE PLAN MENU ACCESS
// =====================================================
export async function updatePlanAccess(req: Request, res: Response) {
  try {
    const { planId, menuId } = req.body;

    if (!planId || !menuId) {
      return sendError({
        res,
        code: 400,
        message: "planId y menuId son requeridos",
        error: "MISSING_PARAMETERS",
      });
    }

    const data = updatePlanMenuAccessSchema.parse(req.body);
    const access = await menuService.updatePlanAccess(planId, menuId, data);

    return sendSuccess({
      res,
      message: "Acceso actualizado exitosamente",
      data: access,
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

    if (error.message === "ACCESS_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Acceso no encontrado",
        error: "ACCESS_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al actualizar acceso",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// REMOVE PLAN ACCESS
// =====================================================
export async function removePlanAccess(req: Request, res: Response) {
  try {
    const { planId, menuId } = req.body;

    if (!planId || !menuId) {
      return sendError({
        res,
        code: 400,
        message: "planId y menuId son requeridos",
        error: "MISSING_PARAMETERS",
      });
    }

    await menuService.removePlanAccess(planId, menuId);

    return sendSuccess({
      res,
      message: "Acceso removido exitosamente",
      data: { planId, menuId },
    });
  } catch (error: any) {
    if (error.message === "ACCESS_NOT_FOUND") {
      return sendError({
        res,
        code: 404,
        message: "Acceso no encontrado",
        error: "ACCESS_NOT_FOUND",
      });
    }

    return sendError({
      res,
      code: 500,
      message: "Error al remover acceso",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// GET PLAN ACCESS
// =====================================================
export async function getPlanAccess(req: Request, res: Response) {
  try {
    const { planId } = req.params;

    if (!planId) {
      return sendError({
        res,
        code: 400,
        message: "planId es requerido",
        error: "MISSING_PARAMETERS",
      });
    }

    const access = await menuService.getPlanAccess(planId);

    return sendSuccess({
      res,
      message: "Accesos del plan obtenidos exitosamente",
      data: access,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener accesos del plan",
      error: "SERVER_ERROR",
    });
  }
}
