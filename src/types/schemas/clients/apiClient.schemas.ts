// =====================================================
// apiClient.schemas.ts
// =====================================================
import { z } from "zod";

export const createApiClientSchema = z.object({
  name: z
    .string({ message: "El nombre es requerido" })
    .min(3, "El nombre debe tener al menos 3 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres"),
  description: z
    .string()
    .max(500, "La descripción no puede exceder 500 caracteres")
    .optional(),
  scopes: z
    .array(z.string(), {
      message: "Los scopes deben ser un arreglo de strings",
    })
    .optional(),
  rateLimit: z
    .number({ message: "El límite de tasa debe ser un número" })
    .int("El límite de tasa debe ser un número entero")
    .min(1, "El límite de tasa debe ser al menos 1")
    .max(100000, "El límite de tasa no puede exceder 100000")
    .optional(),
});

export const updateApiClientSchema = z.object({
  name: z
    .string()
    .min(3, "El nombre debe tener al menos 3 caracteres")
    .max(100, "El nombre no puede exceder 100 caracteres")
    .optional(),
  description: z
    .string()
    .max(500, "La descripción no puede exceder 500 caracteres")
    .optional(),
  scopes: z
    .array(z.string(), {
      message: "Los scopes deben ser un arreglo de strings",
    })
    .optional(),
  rateLimit: z
    .number({ message: "El límite de tasa debe ser un número" })
    .int("El límite de tasa debe ser un número entero")
    .min(1, "El límite de tasa debe ser al menos 1")
    .max(100000, "El límite de tasa no puede exceder 100000")
    .optional(),
  status: z
    .enum(["ACTIVE", "INACTIVE", "SUSPENDED"], {
      message: "El estado debe ser ACTIVE, INACTIVE o SUSPENDED",
    })
    .optional(),
});

export const apiClientIdSchema = z.object({
  id: z
    .string({ message: "El ID es requerido" })
    .uuid("El ID debe ser un UUID válido"),
});
