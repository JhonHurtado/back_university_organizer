// =====================================================
// types/schemas/subscriptions/subscription.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const PlanTypeSchema = z.enum(["FREE", "BASIC", "PREMIUM", "ENTERPRISE"]);
export const BillingCycleSchema = z.enum(["MONTHLY", "QUARTERLY", "SEMI_ANNUAL", "ANNUAL", "LIFETIME"]);
export const SubscriptionStatusSchema = z.enum([
  "TRIAL",
  "ACTIVE",
  "PAST_DUE",
  "EXPIRED",
  "CANCELLED",
  "SUSPENDED",
]);

// =====================================================
// PLAN SCHEMAS
// =====================================================
export const createPlanSchema = z.object({
  name: z.string().min(2, "El nombre debe tener al menos 2 caracteres"),
  slug: z.string().min(2, "El slug debe tener al menos 2 caracteres"),
  description: z.string().optional(),
  price: z.number().nonnegative("El precio no puede ser negativo"),
  currency: z.string().length(3, "La moneda debe tener 3 caracteres (ISO 4217)").default("USD"),
  billingPeriod: BillingCycleSchema.default("MONTHLY"),
  trialDays: z.number().int().nonnegative("Los días de prueba no pueden ser negativos").default(0),
  maxCareers: z.number().int().positive("Debe permitir al menos 1 carrera").default(1),
  maxSubjectsPerCareer: z.number().int().positive().default(50),
  features: z.record(z.string(), z.any()).default({}),
  isActive: z.boolean().default(true),
});

export const updatePlanSchema = z.object({
  name: z.string().min(2).optional(),
  slug: z.string().min(2).optional(),
  description: z.string().optional(),
  price: z.number().nonnegative().optional(),
  currency: z.string().length(3).optional(),
  billingPeriod: BillingCycleSchema.optional(),
  trialDays: z.number().int().nonnegative().optional(),
  maxCareers: z.number().int().positive().optional(),
  maxSubjectsPerCareer: z.number().int().positive().optional(),
  features: z.record(z.string(), z.any()).optional(),
  isActive: z.boolean().optional(),
});

export const planIdSchema = z.object({
  id: z.string().uuid("ID de plan inválido"),
});

// =====================================================
// SUBSCRIPTION SCHEMAS
// =====================================================
export const createSubscriptionSchema = z.object({
  userId: z.string().uuid("ID de usuario inválido"),
  planId: z.string().uuid("ID de plan inválido"),
  status: SubscriptionStatusSchema.default("TRIAL"),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  autoRenew: z.boolean().default(true),
});

export const updateSubscriptionSchema = z.object({
  status: SubscriptionStatusSchema.optional(),
  endDate: z.coerce.date().optional(),
  autoRenew: z.boolean().optional(),
  cancelledAt: z.coerce.date().optional(),
  cancellationReason: z.string().optional(),
});

export const subscriptionIdSchema = z.object({
  id: z.string().uuid("ID de suscripción inválido"),
});

export const changePlanSchema = z.object({
  newPlanId: z.string().uuid("ID de plan inválido"),
  immediate: z.boolean().default(false),
});

export const cancelSubscriptionSchema = z.object({
  reason: z.string().min(10, "La razón debe tener al menos 10 caracteres").optional(),
  immediate: z.boolean().default(false),
});

// =====================================================
// QUERY SCHEMAS
// =====================================================
export const subscriptionQuerySchema = z.object({
  status: SubscriptionStatusSchema.optional(),
  planType: PlanTypeSchema.optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreatePlanInput = z.infer<typeof createPlanSchema>;
export type UpdatePlanInput = z.infer<typeof updatePlanSchema>;
export type CreateSubscriptionInput = z.infer<typeof createSubscriptionSchema>;
export type UpdateSubscriptionInput = z.infer<typeof updateSubscriptionSchema>;
export type ChangePlanInput = z.infer<typeof changePlanSchema>;
export type CancelSubscriptionInput = z.infer<typeof cancelSubscriptionSchema>;
export type SubscriptionQueryInput = z.infer<typeof subscriptionQuerySchema>;
