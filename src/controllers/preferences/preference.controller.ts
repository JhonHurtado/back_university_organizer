// =====================================================
// controllers/preferences/preference.controller.ts
// =====================================================
import type { Request, Response } from "express";
import * as preferenceService from "@/services/preferences/preference.service";
import {
  updatePreferencesSchema,
  updateNotificationPreferencesSchema,
  updateDisplayPreferencesSchema,
  updateAcademicPreferencesSchema,
} from "@/types/schemas/preferences/preference.schemas";
import { ZodError } from "zod";
import {
  sendError,
  sendErrorValidation,
  sendSuccess,
} from "@/utils/response/apiResponse";

// =====================================================
// GET PREFERENCES
// =====================================================
export async function getPreferences(req: Request, res: Response) {
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

    let preferences = await preferenceService.getPreferences(userId);

    // Si no existen preferencias, crearlas con valores por defecto
    if (!preferences) {
      preferences = await preferenceService.createPreferences(userId);
    }

    return sendSuccess({
      res,
      message: "Preferencias obtenidas exitosamente",
      data: preferences,
    });
  } catch (error: any) {
    return sendError({
      res,
      code: 500,
      message: "Error al obtener preferencias",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE PREFERENCES (GENERAL)
// =====================================================
export async function updatePreferences(req: Request, res: Response) {
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

    const data = updatePreferencesSchema.parse(req.body);
    const preferences = await preferenceService.updatePreferences(userId, data);

    return sendSuccess({
      res,
      message: "Preferencias actualizadas exitosamente",
      data: preferences,
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
      message: "Error al actualizar preferencias",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE NOTIFICATION PREFERENCES
// =====================================================
export async function updateNotificationPreferences(
  req: Request,
  res: Response
) {
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

    const data = updateNotificationPreferencesSchema.parse(req.body);
    const preferences = await preferenceService.updateNotificationPreferences(
      userId,
      data
    );

    return sendSuccess({
      res,
      message: "Preferencias de notificación actualizadas exitosamente",
      data: preferences,
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
      message: "Error al actualizar preferencias de notificación",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE DISPLAY PREFERENCES
// =====================================================
export async function updateDisplayPreferences(req: Request, res: Response) {
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

    const data = updateDisplayPreferencesSchema.parse(req.body);
    const preferences = await preferenceService.updateDisplayPreferences(
      userId,
      data
    );

    return sendSuccess({
      res,
      message: "Preferencias de visualización actualizadas exitosamente",
      data: preferences,
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
      message: "Error al actualizar preferencias de visualización",
      error: "SERVER_ERROR",
    });
  }
}

// =====================================================
// UPDATE ACADEMIC PREFERENCES
// =====================================================
export async function updateAcademicPreferences(req: Request, res: Response) {
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

    const data = updateAcademicPreferencesSchema.parse(req.body);
    const preferences = await preferenceService.updateAcademicPreferences(
      userId,
      data
    );

    return sendSuccess({
      res,
      message: "Preferencias académicas actualizadas exitosamente",
      data: preferences,
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
      message: "Error al actualizar preferencias académicas",
      error: "SERVER_ERROR",
    });
  }
}
