// =====================================================
// types/schemas/menus/menu.schemas.ts
// =====================================================

import { z } from "zod";

// =====================================================
// CREATE MENU SCHEMA
// =====================================================
export const createMenuSchema = z.object({
  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres"),
  label: z
    .string()
    .min(1, "El label es requerido")
    .max(100, "El label no puede exceder 100 caracteres"),
  labelKey: z.string().max(100).optional(),
  icon: z.string().max(50).optional(),
  path: z.string().max(200).optional(),
  externalUrl: z.string().url("URL inválida").optional(),
  target: z.enum(["_self", "_blank", "_parent", "_top"]).default("_self"),
  parentId: z.string().uuid("ID de menú padre inválido").optional(),
  sortOrder: z.number().int().min(0).default(0),
  isActive: z.boolean().default(true),
  isPremium: z.boolean().default(false),
  badge: z.string().max(20).optional(),
  badgeColor: z.string().max(20).optional(),
});

// =====================================================
// UPDATE MENU SCHEMA
// =====================================================
export const updateMenuSchema = z.object({
  name: z
    .string()
    .min(2, "El nombre debe tener al menos 2 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres")
    .optional(),
  label: z
    .string()
    .min(1, "El label es requerido")
    .max(100, "El label no puede exceder 100 caracteres")
    .optional(),
  labelKey: z.string().max(100).optional(),
  icon: z.string().max(50).optional(),
  path: z.string().max(200).optional(),
  externalUrl: z.string().url("URL inválida").optional(),
  target: z.enum(["_self", "_blank", "_parent", "_top"]).optional(),
  parentId: z.string().uuid("ID de menú padre inválido").nullable().optional(),
  sortOrder: z.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
  isPremium: z.boolean().optional(),
  badge: z.string().max(20).optional(),
  badgeColor: z.string().max(20).optional(),
});

// =====================================================
// MENU ID SCHEMA
// =====================================================
export const menuIdSchema = z.object({
  id: z.string().uuid("ID de menú inválido"),
});

// =====================================================
// PLAN MENU ACCESS SCHEMA
// =====================================================
export const planMenuAccessSchema = z.object({
  planId: z.string().uuid("ID de plan inválido"),
  menuId: z.string().uuid("ID de menú inválido"),
  canView: z.boolean().default(true),
  canCreate: z.boolean().default(false),
  canEdit: z.boolean().default(false),
  canDelete: z.boolean().default(false),
  canExport: z.boolean().default(false),
});

// =====================================================
// UPDATE PLAN MENU ACCESS SCHEMA
// =====================================================
export const updatePlanMenuAccessSchema = z.object({
  canView: z.boolean().optional(),
  canCreate: z.boolean().optional(),
  canEdit: z.boolean().optional(),
  canDelete: z.boolean().optional(),
  canExport: z.boolean().optional(),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreateMenuInput = z.infer<typeof createMenuSchema>;
export type UpdateMenuInput = z.infer<typeof updateMenuSchema>;
export type MenuIdInput = z.infer<typeof menuIdSchema>;
export type PlanMenuAccessInput = z.infer<typeof planMenuAccessSchema>;
export type UpdatePlanMenuAccessInput = z.infer<
  typeof updatePlanMenuAccessSchema
>;
