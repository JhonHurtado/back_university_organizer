// =====================================================
// controllers/subscriptions/subscription.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { subscriptionService } from "@/services/subscriptions/subscription.service";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendBadRequest,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as subscriptionSchemas from "@/types/schemas/subscriptions/subscription.schemas";

// =====================================================
// PLAN CONTROLLERS
// =====================================================
export async function createPlan(req: Request, res: Response) {
  try {
    const data = subscriptionSchemas.createPlanSchema.parse(req.body);
    const plan = await subscriptionService.createPlan(data);
    return sendCreated({ res, message: "Plan creado exitosamente", data: plan });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendServerError({ res, message: "Error al crear plan" });
  }
}

export async function getAllPlans(req: Request, res: Response) {
  try {
    const activeOnly = req.query.activeOnly !== "false";
    const plans = await subscriptionService.getAllPlans(activeOnly);
    return sendSuccess({ res, message: "Planes obtenidos exitosamente", data: plans });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener planes" });
  }
}

export async function getPlanById(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.planIdSchema.parse(req.params);
    const plan = await subscriptionService.getPlanById(id);
    if (!plan) return sendNotFound({ res, message: "Plan no encontrado" });
    return sendSuccess({ res, message: "Plan obtenido exitosamente", data: plan });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener plan" });
  }
}

export async function updatePlan(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.planIdSchema.parse(req.params);
    const data = subscriptionSchemas.updatePlanSchema.parse(req.body);
    const plan = await subscriptionService.updatePlan(id, data);
    return sendSuccess({ res, message: "Plan actualizado exitosamente", data: plan });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    return sendServerError({ res, message: "Error al actualizar plan" });
  }
}

export async function deletePlan(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.planIdSchema.parse(req.params);
    await subscriptionService.deletePlan(id);
    return sendSuccess({ res, message: "Plan eliminado exitosamente" });
  } catch (error: any) {
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    if (error.message === "PLAN_HAS_ACTIVE_SUBSCRIPTIONS") {
      return sendBadRequest({ res, message: "No se puede eliminar un plan con suscripciones activas" });
    }
    return sendServerError({ res, message: "Error al eliminar plan" });
  }
}

// =====================================================
// SUBSCRIPTION CONTROLLERS
// =====================================================
export async function createSubscription(req: Request, res: Response) {
  try {
    const data = subscriptionSchemas.createSubscriptionSchema.parse(req.body);
    const subscription = await subscriptionService.createSubscription(data);
    return sendCreated({ res, message: "Suscripción creada exitosamente", data: subscription });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "USER_NOT_FOUND") return sendNotFound({ res, message: "Usuario no encontrado" });
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    if (error.message === "USER_HAS_ACTIVE_SUBSCRIPTION") {
      return sendBadRequest({ res, message: "El usuario ya tiene una suscripción activa" });
    }
    return sendServerError({ res, message: "Error al crear suscripción" });
  }
}

export async function getSubscriptionsByUser(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const filters = subscriptionSchemas.subscriptionQuerySchema.parse(req.query);
    const result = await subscriptionService.getSubscriptionsByUser(userId, filters);
    return sendSuccess({ res, message: "Suscripciones obtenidas exitosamente", data: result });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendServerError({ res, message: "Error al obtener suscripciones" });
  }
}

export async function getActiveSubscription(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const subscription = await subscriptionService.getActiveSubscription(userId);
    if (!subscription) {
      return sendNotFound({ res, message: "No se encontró suscripción activa" });
    }
    return sendSuccess({ res, message: "Suscripción activa obtenida exitosamente", data: subscription });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener suscripción activa" });
  }
}

export async function getSubscriptionById(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.subscriptionIdSchema.parse(req.params);
    const subscription = await subscriptionService.getSubscriptionById(id);
    if (!subscription) {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    return sendSuccess({ res, message: "Suscripción obtenida exitosamente", data: subscription });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener suscripción" });
  }
}

export async function updateSubscription(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.subscriptionIdSchema.parse(req.params);
    const data = subscriptionSchemas.updateSubscriptionSchema.parse(req.body);
    const subscription = await subscriptionService.updateSubscription(id, data);
    return sendSuccess({ res, message: "Suscripción actualizada exitosamente", data: subscription });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    return sendServerError({ res, message: "Error al actualizar suscripción" });
  }
}

export async function changePlan(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = subscriptionSchemas.subscriptionIdSchema.parse(req.params);
    const data = subscriptionSchemas.changePlanSchema.parse(req.body);
    const subscription = await subscriptionService.changePlan(id, userId, data);
    return sendSuccess({
      res,
      message: data.immediate
        ? "Plan cambiado exitosamente"
        : "Cambio de plan programado para el próximo ciclo de facturación",
      data: subscription,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    return sendServerError({ res, message: "Error al cambiar plan" });
  }
}

export async function cancelSubscription(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { id } = subscriptionSchemas.subscriptionIdSchema.parse(req.params);
    const data = subscriptionSchemas.cancelSubscriptionSchema.parse(req.body);
    const subscription = await subscriptionService.cancelSubscription(id, userId, data);
    return sendSuccess({
      res,
      message: data.immediate
        ? "Suscripción cancelada exitosamente"
        : "Suscripción cancelada. Tendrás acceso hasta el final del período actual",
      data: subscription,
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    return sendServerError({ res, message: "Error al cancelar suscripción" });
  }
}

export async function renewSubscription(req: Request, res: Response) {
  try {
    const { id } = subscriptionSchemas.subscriptionIdSchema.parse(req.params);
    const subscription = await subscriptionService.renewSubscription(id);
    return sendSuccess({ res, message: "Suscripción renovada exitosamente", data: subscription });
  } catch (error: any) {
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    if (error.message === "PLAN_NOT_FOUND") return sendNotFound({ res, message: "Plan no encontrado" });
    return sendServerError({ res, message: "Error al renovar suscripción" });
  }
}

// =====================================================
// FEATURE VALIDATION CONTROLLERS
// =====================================================
export async function validateFeatureAccess(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { featureName } = req.params;
    const hasAccess = await subscriptionService.validateFeatureAccess(userId, featureName);
    return sendSuccess({
      res,
      message: "Validación de acceso completada",
      data: { featureName, hasAccess },
    });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al validar acceso" });
  }
}

export async function validateCareerLimit(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const result = await subscriptionService.validateCareerLimit(userId);
    return sendSuccess({ res, message: "Validación de límite de carreras completada", data: result });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al validar límite" });
  }
}

export async function validateSubjectLimit(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const { careerId } = req.params;
    const result = await subscriptionService.validateSubjectLimit(userId, careerId);
    return sendSuccess({ res, message: "Validación de límite de materias completada", data: result });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al validar límite" });
  }
}
