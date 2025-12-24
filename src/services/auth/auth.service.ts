import bcrypt from "bcrypt";
import { OAuth2Client } from "google-auth-library";
import { ENV } from "@/config/config";
import database from "@/lib/prisma/prisma";
import type { GoogleTokenPayload } from "@/types/jwt/JWT.types";
import type { User } from "@prisma/client";
import { createEmailVerificationToken } from "@/services/verification/verificationToken.service";
import { emailService } from "@/services/email/email.service";
import {
  buildAuthResponse,
  invalidateSession,
  invalidateAllSessions,
  refreshAccessToken,
} from "@/config/auth/token.service";

const googleClient = new OAuth2Client(ENV.GOOGLE_CLIENT_ID);

export class AuthService {
  // =====================================================
  // Registro
  // =====================================================
  async register(data: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
  }) {
    try {
      const email = data.email.toLowerCase().trim();

      const exists = await database.user.findUnique({ where: { email } });
      if (exists) throw new Error("EMAIL_EXISTS");

      const hashedPassword = await bcrypt.hash(data.password, 12);

      const user = await database.user.create({
        data: {
          email,
          password: hashedPassword,
          firstName: data.firstName,
          lastName: data.lastName,
          preferences: { create: {} },
        },
        include: { subscription: { include: { plan: true } } },
      });

      // Enviar email de verificación
      try {
        const verificationToken = await createEmailVerificationToken(user.id);
        await emailService.sendVerificationEmail(
          user.email,
          user.firstName,
          verificationToken.token
        );
      } catch (error) {
        console.error("Failed to send verification email:", error);
        // No fallar el registro si falla el envío del email
      }

      return user;
    } catch (error) {
      console.error("AuthService.register error:", error);
      throw error;
    }
  }

  // =====================================================
  // Construir respuesta de autenticación (delegado)
  // =====================================================
  async buildAuthResponse(user: User, clientId: string) {
    return buildAuthResponse(user, clientId);
  }

  // =====================================================
  // Refresh Token (delegado)
  // =====================================================
  async refreshToken(refreshToken: string, clientId: string) {
    return refreshAccessToken(refreshToken, clientId);
  }

  // =====================================================
  // Invalidar sesión (delegado)
  // =====================================================
  async invalidateSession(sessionId: string) {
    return invalidateSession(sessionId);
  }

  // =====================================================
  // Invalidar todas las sesiones (delegado)
  // =====================================================
  async invalidateAllSessions(userId: string) {
    return invalidateAllSessions(userId);
  }

  // =====================================================
  // Google OAuth - Verificar token
  // =====================================================
  async verifyGoogleToken(idToken?: string, accessToken?: string) {
    try {
      let email: string | undefined;
      let googleId: string | undefined;
      let firstName: string | undefined;
      let lastName: string | undefined;
      let avatar: string | undefined;

      if (idToken) {
        const ticket = await googleClient.verifyIdToken({
          idToken,
          audience: ENV.GOOGLE_CLIENT_ID,
        });

        const payload = ticket.getPayload();
        if (!payload?.email) throw new Error("INVALID_TOKEN");

        email = payload.email.toLowerCase();
        googleId = payload.sub;
        firstName = payload.given_name;
        lastName = payload.family_name;
        avatar = payload.picture;
      } else if (accessToken) {
        const response = await fetch(
          `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${accessToken}`
        );

        if (!response.ok) throw new Error("INVALID_TOKEN");

        const payload = (await response.json()) as GoogleTokenPayload;
        if (!payload.email) throw new Error("INVALID_TOKEN");

        email = payload.email.toLowerCase();
        googleId = payload.sub;
        firstName = payload.given_name;
        lastName = payload.family_name;
        avatar = payload.picture;
      }

      if (!email || !googleId) throw new Error("INVALID_TOKEN");

      return { email, googleId, firstName, lastName, avatar };
    } catch (error) {
      console.error("AuthService.verifyGoogleToken error:", error);
      throw error;
    }
  }

  // =====================================================
  // Google OAuth - Buscar o crear usuario
  // =====================================================
  async findOrCreateGoogleUser(googleData: {
    email: string;
    googleId: string;
    firstName?: string;
    lastName?: string;
    avatar?: string;
  }) {
    try {
      let account = await database.account.findUnique({
        where: {
          provider_providerAccountId: {
            provider: "google",
            providerAccountId: googleData.googleId,
          },
        },
        include: {
          user: { include: { subscription: { include: { plan: true } } } },
        },
      });

      if (account) {
        if (!account.user.isActive || account.user.deletedAt) {
          throw new Error("ACCOUNT_DISABLED");
        }
        return account.user;
      }

      let user = await database.user.findUnique({
        where: { email: googleData.email },
        include: { subscription: { include: { plan: true } } },
      });

      if (user) {
        await database.account.create({
          data: {
            userId: user.id,
            provider: "google",
            providerAccountId: googleData.googleId,
            type: "oauth",
          },
        });

        if (!user.emailVerified) {
          user = await database.user.update({
            where: { id: user.id },
            data: { emailVerified: true, emailVerifiedAt: new Date() },
            include: { subscription: { include: { plan: true } } },
          });
        }

        return user;
      }

      return await database.user.create({
        data: {
          email: googleData.email,
          firstName: googleData.firstName || "Usuario",
          lastName: googleData.lastName || "",
          avatar: googleData.avatar,
          emailVerified: true,
          emailVerifiedAt: new Date(),
          accounts: {
            create: {
              provider: "google",
              providerAccountId: googleData.googleId,
              type: "oauth",
            },
          },
          preferences: { create: {} },
        },
        include: { subscription: { include: { plan: true } } },
      });
    } catch (error) {
      console.error("AuthService.findOrCreateGoogleUser error:", error);
      throw error;
    }
  }

  // =====================================================
  // Actualizar último login
  // =====================================================
  async updateLastLogin(userId: string) {
    try {
      return await database.user.update({
        where: { id: userId },
        data: { lastLoginAt: new Date() },
      });
    } catch (error) {
      console.error("AuthService.updateLastLogin error:", error);
      throw error;
    }
  }

  // =====================================================
  // Obtener el API Client por defecto
  // =====================================================
  async getDefaultClient() {
    try {
      return await database.apiClient.findFirst({
        where: { status: "ACTIVE" },
      });
    } catch (error) {
      console.error("AuthService.getDefaultClient error:", error);
      throw error;
    }
  }
}
