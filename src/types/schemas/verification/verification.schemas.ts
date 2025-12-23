// =====================================================
// types/schemas/verification/verification.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// VERIFY EMAIL SCHEMA
// =====================================================
export const verifyEmailSchema = z.object({
  token: z.string().uuid("Token inválido"),
});

// =====================================================
// RESEND VERIFICATION EMAIL SCHEMA
// =====================================================
export const resendVerificationEmailSchema = z.object({
  email: z.string().email("Email inválido"),
});

// =====================================================
// REQUEST PASSWORD RESET SCHEMA
// =====================================================
export const requestPasswordResetSchema = z.object({
  email: z.string().email("Email inválido"),
});

// =====================================================
// RESET PASSWORD SCHEMA
// =====================================================
export const resetPasswordSchema = z.object({
  token: z.string().uuid("Token inválido"),
  password: z
    .string()
    .min(8, "La contraseña debe tener al menos 8 caracteres")
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      "La contraseña debe contener al menos una mayúscula, una minúscula y un número"
    ),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Las contraseñas no coinciden",
  path: ["confirmPassword"],
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type VerifyEmailInput = z.infer<typeof verifyEmailSchema>;
export type ResendVerificationEmailInput = z.infer<typeof resendVerificationEmailSchema>;
export type RequestPasswordResetInput = z.infer<typeof requestPasswordResetSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
