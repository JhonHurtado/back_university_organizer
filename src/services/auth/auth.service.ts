import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import { ENV } from "@/config/config";
import database from "@/lib/prisma/prisma";
import type { GoogleTokenPayload } from "@/types/jwt/JWT.types";
import { User } from "generated/prisma/client";
import crypto from "crypto";

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

      return await database.user.create({
        data: {
          email,
          password: hashedPassword,
          firstName: data.firstName,
          lastName: data.lastName,
          preferences: { create: {} },
        },
        include: { subscription: { include: { plan: true } } },
      });
    } catch (error) {
      console.error("AuthService.register error:", error);
      throw error;
    }
  }

  // =====================================================
  // Crear sesión y tokens
  // =====================================================
  async createSession(
    userId: string,
    clientId: string,
    ipAddress?: string,
    userAgent?: string
  ) {
    try {
      // Generar tokens ANTES de crear la sesión
      const sessionId = crypto.randomUUID();

      const accessToken = jwt.sign(
        { sub: userId, sessionId, clientId },
        ENV.JWT_SECRET,
        { expiresIn: "15m", issuer: ENV.JWT_ISSUER }
      );

      const refreshToken = jwt.sign(
        { sub: userId, sessionId, type: "refresh" },
        ENV.JWT_SECRET,
        { expiresIn: "7d", issuer: ENV.JWT_ISSUER }
      );

      // Crear sesión con tokens ya generados
      await database.session.create({
        data: {
          id: sessionId,
          userId,
          token: accessToken,
          refreshToken,
          expiresAt: new Date(Date.now() + 15 * 60 * 1000),
          ipAddress,
          userAgent,
        },
      });

      return { accessToken, refreshToken, expiresIn: 900 };
    } catch (error) {
      console.error("AuthService.createSession error:", error);
      throw error;
    }
  }

  // =====================================================
  // Refresh Token
  // =====================================================
  async refreshToken(refreshToken: string, clientId: string) {
    try {
      const decoded = jwt.verify(refreshToken, ENV.JWT_SECRET, {
        algorithms: ["HS256"],
        issuer: ENV.JWT_ISSUER,
      }) as any;

      if (decoded.type !== "refresh") throw new Error("INVALID_TOKEN");

      const session = await database.session.findUnique({
        where: { refreshToken },
        include: {
          user: { include: { subscription: { include: { plan: true } } } },
        },
      });

      if (!session?.isValid || new Date() > session.expiresAt) {
        throw new Error("INVALID_SESSION");
      }

      const user = session.user;
      if (!user.isActive || user.deletedAt) throw new Error("USER_DISABLED");

      const accessToken = jwt.sign(
        { sub: user.id, sessionId: session.id, clientId },
        ENV.JWT_SECRET,
        { expiresIn: "15m", issuer: ENV.JWT_ISSUER }
      );

      await database.session.update({
        where: { id: session.id },
        data: {
          token: accessToken,
          expiresAt: new Date(Date.now() + 15 * 60 * 1000),
        },
      });

      return { accessToken, user, expiresIn: 900 };
    } catch (error) {
      console.error("AuthService.refreshToken error:", error);
      throw error;
    }
  }

  // =====================================================
  // Invalidar sesión
  // =====================================================
  async invalidateSession(sessionId: string) {
    try {
      return await database.session.update({
        where: { id: sessionId },
        data: { isValid: false },
      });
    } catch (error) {
      console.error("AuthService.invalidateSession error:", error);
      throw error;
    }
  }

  // =====================================================
  // Invalidar todas las sesiones
  // =====================================================
  async invalidateAllSessions(userId: string) {
    try {
      return await database.session.updateMany({
        where: { userId, isValid: true },
        data: { isValid: false },
      });
    } catch (error) {
      console.error("AuthService.invalidateAllSessions error:", error);
      throw error;
    }
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
  // Construir respuesta de autenticación
  // =====================================================
  async buildAuthResponse(
    user: User,
    clientId: string,
    ipAddress?: string,
    userAgent?: string
  ) {
    try {
      const { accessToken, refreshToken, expiresIn } = await this.createSession(
        user.id,
        clientId,
        ipAddress,
        userAgent
      );

      await this.updateLastLogin(user.id);

      return {
        access_token: accessToken,
        refresh_token: refreshToken,
        token_type: "Bearer",
        expires_in: expiresIn,
        user: {
          id: user.id,
          email: user.email,
          fullName: `${user.firstName} ${user.lastName}`,
        },
      };
    } catch (error) {
      console.error("AuthService.buildAuthResponse error:", error);
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
