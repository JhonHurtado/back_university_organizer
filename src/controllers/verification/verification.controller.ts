// =====================================================
// controllers/verification/verification.controller.ts
// =====================================================
import type { Request, Response } from "express";
import {
  sendSuccess,
  sendBadRequest,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as verificationSchemas from "@/types/schemas/verification/verification.schemas";
import * as verificationTokenService from "@/services/verification/verificationToken.service";
import { emailService } from "@/services/email/email.service";
import database from "@/lib/prisma/prisma";
import bcrypt from "bcrypt";

// =====================================================
// VERIFY EMAIL
// =====================================================
export async function verifyEmail(req: Request, res: Response) {
  try {
    const { token } = verificationSchemas.verifyEmailSchema.parse(req.query);

    // Verificar el token
    const verificationRecord = await verificationTokenService.verifyToken(
      token,
      "EMAIL_VERIFICATION"
    );

    if (!verificationRecord) {
      return sendBadRequest({ res, message: "Token inválido o expirado",
      });
    }

    // Actualizar el usuario como verificado
    await database.user.update({
      where: { id: verificationRecord.userId },
      data: {
        emailVerified: true,
        emailVerifiedAt: new Date(),
      },
    });

    // Marcar el token como usado
    await verificationTokenService.useToken(verificationRecord.id);

    // Enviar email de bienvenida
    try {
      await emailService.sendWelcomeEmail(
        verificationRecord.user.email,
        verificationRecord.user.firstName
      );
    } catch (error) {
      console.error("Failed to send welcome email:", error);
      // No fallar la verificación si falla el envío del welcome email
    }

    return sendSuccess({
      res,
      message: "Email verificado exitosamente",
      data: {
        verified: true,
        email: verificationRecord.user.email,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendServerError({ res, message: "Error al verificar el email",
    });
  }
}

// =====================================================
// RESEND VERIFICATION EMAIL
// =====================================================
export async function resendVerificationEmail(req: Request, res: Response) {
  try {
    const { email } = verificationSchemas.resendVerificationEmailSchema.parse(req.body);

    // Buscar el usuario
    const user = await database.user.findUnique({
      where: { email },
    });

    if (!user) {
      // No revelar si el email existe o no por seguridad
      return sendSuccess({
        res,
        message: "Si el email existe, recibirás un correo de verificación",
      });
    }

    // Si ya está verificado, no hacer nada
    if (user.emailVerified) {
      return sendBadRequest({ res, message: "El email ya está verificado",
      });
    }

    // Crear nuevo token de verificación
    const verificationToken = await verificationTokenService.createEmailVerificationToken(user.id);

    // Enviar email de verificación
    await emailService.sendVerificationEmail(
      user.email,
      user.firstName,
      verificationToken.token
    );

    return sendSuccess({
      res,
      message: "Email de verificación enviado exitosamente",
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendServerError({ res, message: "Error al enviar el email de verificación",
    });
  }
}

// =====================================================
// REQUEST PASSWORD RESET
// =====================================================
export async function requestPasswordReset(req: Request, res: Response) {
  try {
    const { email } = verificationSchemas.requestPasswordResetSchema.parse(req.body);

    // Buscar el usuario
    const user = await database.user.findUnique({
      where: { email },
    });

    if (!user) {
      // No revelar si el email existe o no por seguridad
      return sendSuccess({
        res,
        message: "Si el email existe, recibirás instrucciones para restablecer tu contraseña",
      });
    }

    // Crear token de reset de contraseña
    const resetToken = await verificationTokenService.createPasswordResetToken(user.id);

    // Enviar email de reset
    await emailService.sendPasswordResetEmail(
      user.email,
      user.firstName,
      resetToken.token
    );

    return sendSuccess({
      res,
      message: "Si el email existe, recibirás instrucciones para restablecer tu contraseña",
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendServerError({ res, message: "Error al procesar la solicitud",
    });
  }
}

// =====================================================
// RESET PASSWORD
// =====================================================
export async function resetPassword(req: Request, res: Response) {
  try {
    const { token, password } = verificationSchemas.resetPasswordSchema.parse(req.body);

    // Verificar el token
    const verificationRecord = await verificationTokenService.verifyToken(
      token,
      "PASSWORD_RESET"
    );

    if (!verificationRecord) {
      return sendBadRequest({ res, message: "Token inválido o expirado",
      });
    }

    // Hashear la nueva contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Actualizar la contraseña del usuario
    await database.user.update({
      where: { id: verificationRecord.userId },
      data: {
        password: hashedPassword,
      },
    });

    // Marcar el token como usado
    await verificationTokenService.useToken(verificationRecord.id);

    // Invalidar todas las sesiones del usuario por seguridad
    await database.session.updateMany({
      where: { userId: verificationRecord.userId },
      data: { isValid: false },
    });

    return sendSuccess({
      res,
      message: "Contraseña restablecida exitosamente",
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({
        res,
        errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}),
      });
    }
    return sendServerError({ res, message: "Error al restablecer la contraseña",
    });
  }
}
