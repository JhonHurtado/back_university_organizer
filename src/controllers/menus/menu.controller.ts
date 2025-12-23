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
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendConflict,
  sendBadRequest,
  sendServerError,
  sendValidationError,
  sendUnauthorized,
} from "@/utils/response/apiResponse";

// =====================================================
// CREATE MENU
// =====================================================
export async function create(req: Request, res: Response) {
  try {
    const data = createMenuSchema.parse(req.body);
    const menu = await menuService.create(data);

    return sendCreated({
      res,
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "PARENT_MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú padre no encontrado",
      });
    }

    if (error.message === "MENU_NAME_EXISTS") {
      return sendConflict({ res, message: "Ya existe un menú con ese nombre",
      });
    }

    return sendServerError({ res, message: "Error al crear menú",
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
    return sendServerError({ res, message: "Error al obtener menús",
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
    return sendServerError({ res, message: "Error al obtener árbol de menús",
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
      return sendUnauthorized({ res, message: "No autenticado",
      });
    }

    const menuTree = await menuService.getMenuTreeByUser(userId);

    return sendSuccess({
      res,
      message: "Menú del usuario obtenido exitosamente",
      data: menuTree,
    });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener menú del usuario",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al obtener menú",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú no encontrado",
      });
    }

    if (error.message === "PARENT_MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú padre no encontrado",
      });
    }

    if (error.message === "CIRCULAR_REFERENCE") {
      return sendBadRequest({ res, message: "No se puede asignar el menú como su propio padre",
      });
    }

    if (error.message === "MENU_NAME_EXISTS") {
      return sendConflict({ res, message: "Ya existe un menú con ese nombre",
      });
    }

    return sendServerError({ res, message: "Error al actualizar menú",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú no encontrado",
      });
    }

    if (error.message === "MENU_HAS_CHILDREN") {
      return sendBadRequest({ res, message: "No se puede eliminar un menú que tiene submenús",
      });
    }

    return sendServerError({ res, message: "Error al eliminar menú",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú no encontrado o ya está activo",
      });
    }

    return sendServerError({ res, message: "Error al restaurar menú",
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

    return sendCreated({
      res,
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "MENU_NOT_FOUND") {
      return sendNotFound({ res, message: "Menú no encontrado",
      });
    }

    if (error.message === "PLAN_NOT_FOUND") {
      return sendNotFound({ res, message: "Plan no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al asignar acceso",
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
      return sendBadRequest({ res, message: "planId y menuId son requeridos",
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

      return sendValidationError({ res, errors });
    }

    if (error.message === "ACCESS_NOT_FOUND") {
      return sendNotFound({ res, message: "Acceso no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al actualizar acceso",
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
      return sendBadRequest({ res, message: "planId y menuId son requeridos",
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
      return sendNotFound({ res, message: "Acceso no encontrado",
      });
    }

    return sendServerError({ res, message: "Error al remover acceso",
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
      return sendBadRequest({ res, message: "planId es requerido",
      });
    }

    const access = await menuService.getPlanAccess(planId);

    return sendSuccess({
      res,
      message: "Accesos del plan obtenidos exitosamente",
      data: access,
    });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener accesos del plan",
    });
  }
}
