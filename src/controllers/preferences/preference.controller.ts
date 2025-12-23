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
  sendSuccess,
  sendServerError,
  sendValidationError,
  sendUnauthorized,
} from "@/utils/response/apiResponse";

// =====================================================
// GET PREFERENCES
// =====================================================
export async function getPreferences(req: Request, res: Response) {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return sendUnauthorized({ res, message: "No autenticado",
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
    return sendServerError({ res, message: "Error al obtener preferencias",
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
      return sendUnauthorized({ res, message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({ res, message: "Error al actualizar preferencias",
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
      return sendUnauthorized({ res, message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({ res, message: "Error al actualizar preferencias de notificación",
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
      return sendUnauthorized({ res, message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({ res, message: "Error al actualizar preferencias de visualización",
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
      return sendUnauthorized({ res, message: "No autenticado",
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

      return sendValidationError({ res, errors });
    }

    return sendServerError({ res, message: "Error al actualizar preferencias académicas",
    });
  }
}
