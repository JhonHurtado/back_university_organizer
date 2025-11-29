import { z } from "zod";

export const createUserSchema = z.object({
  email: z.string().email("Email inválido"),
  password: z.string().min(8, "Mínimo 8 caracteres").optional(),
  firstName: z.string().min(2, "Mínimo 2 caracteres"),
  lastName: z.string().min(2, "Mínimo 2 caracteres"),
  phone: z.string().optional(),
  timezone: z.string().optional(),
  language: z.string().optional(),
});

export const updateUserSchema = z.object({
  email: z.string().email("Email inválido").optional(),
  firstName: z.string().min(2, "Mínimo 2 caracteres").optional(),
  lastName: z.string().min(2, "Mínimo 2 caracteres").optional(),
  phone: z.string().optional(),
  avatar: z.string().url("URL inválida").optional(),
  timezone: z.string().optional(),
  language: z.string().optional(),
});

export const updatePasswordSchema = z.object({
  password: z.string().min(8, "Mínimo 8 caracteres"),
});

export const userIdSchema = z.object({
  id: z.string().uuid("UUID inválido"),
});