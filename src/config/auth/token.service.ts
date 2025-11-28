// =====================================================
// token.service.ts
// =====================================================
import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";
import type { JWTPayload } from "@/types/jwt/JWT.types";
import { ENV } from "../config";
import database from "@/lib/prisma/prisma";

const ACCESS_TOKEN_EXPIRY: number = Number(ENV.TOKEN_EXPIRATION) || 3600; // segundos
const REFRESH_TOKEN_EXPIRY = "7d";

// =====================================================
// GENERAR TOKENS
// =====================================================
export async function generateTokens(user: any, clientId: string) {
  // Crear sesión
  const session = await database.session.create({
    data: {
      userId: user.id,
      token: randomUUID(),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      isValid: true,
    },
  });

  // Access token
  const payload: JWTPayload = {
    sub: user.id,
    sessionId: session.id,
    email: user.email,
    scope: ["read", "write"],
  };

  const accessToken = jwt.sign(payload, ENV.JWT_SECRET, {
    algorithm: "HS256" as any,
    expiresIn: ACCESS_TOKEN_EXPIRY,
    issuer: ENV.JWT_ISSUER,
    audience: clientId,
  });

  // Refresh token
  const refreshToken = jwt.sign(
    { sub: user.id, sessionId: session.id, type: "refresh" },
    ENV.JWT_REFRESH_SECRET,
    {
      algorithm: "HS256" as any,
      expiresIn: REFRESH_TOKEN_EXPIRY,
      issuer: ENV.JWT_ISSUER,
      audience: clientId,
    }
  );

  // Actualizar último login
  await database.user.update({
    where: { id: user.id },
    data: { lastLoginAt: new Date() },
  });

  return { accessToken, refreshToken, expiresIn: ACCESS_TOKEN_EXPIRY };
}

// =====================================================
// REFRESH TOKEN
// =====================================================
export async function refreshAccessToken(refreshToken: string, clientId: string) {
  const decoded = jwt.verify(refreshToken, ENV.JWT_REFRESH_SECRET, {
    algorithms: ["HS256"],
    issuer: ENV.JWT_ISSUER,
  }) as { sub: string; sessionId: string; type: string; aud: string };

  if (decoded.type !== "refresh" || decoded.aud !== clientId) {
    throw new Error("Invalid refresh token");
  }

  // Validar sesión
  const session = await database.session.findUnique({
    where: { id: decoded.sessionId },
  });

  if (!session?.isValid || new Date() > session.expiresAt) {
    throw new Error("Session expired");
  }

  // Validar usuario
  const user = await database.user.findUnique({
    where: { id: decoded.sub },
    include: { subscription: { include: { plan: true } } },
  });

  if (!user || !user.isActive || user.deletedAt) {
    await database.session.update({
      where: { id: session.id },
      data: { isValid: false },
    });
    throw new Error("User not found");
  }

  // Nuevo access token
  const payload: JWTPayload = {
    sub: user.id,
    sessionId: session.id,
    email: user.email,
    scope: ["read", "write"],
  };

  const accessToken = jwt.sign(payload, ENV.JWT_SECRET, {
    algorithm: "HS256" as any,
    expiresIn: ACCESS_TOKEN_EXPIRY,
    issuer: ENV.JWT_ISSUER,
    audience: clientId,
  });

  return { accessToken, user, expiresIn: ACCESS_TOKEN_EXPIRY };
}

// =====================================================
// INVALIDAR SESIÓN (LOGOUT)
// =====================================================
export async function invalidateSession(sessionId: string) {
  await database.session.update({
    where: { id: sessionId },
    data: { isValid: false },
  });
}

// =====================================================
// INVALIDAR TODAS LAS SESIONES
// =====================================================
export async function invalidateAllSessions(userId: string) {
  await database.session.updateMany({
    where: { userId, isValid: true },
    data: { isValid: false },
  });
}

// =====================================================
// OBTENER MENÚS POR PLAN
// =====================================================
export async function getMenusByPlan(planId?: string) {
  return database.menu.findMany({
    where: {
      isActive: true,
      OR: [
        { isPremium: false },
        ...(planId
          ? [{ planAccess: { some: { planId, canView: true } } }]
          : []),
      ],
    },
    include: {
      children: {
        where: { isActive: true },
        orderBy: { sortOrder: "asc" },
      },
    },
    orderBy: { sortOrder: "asc" },
  });
}

// =====================================================
// CONSTRUIR RESPUESTA DE AUTH
// =====================================================
export async function buildAuthResponse(user: any, clientId: string) {
  const { accessToken, refreshToken, expiresIn } = await generateTokens(user, clientId);
  const menu = await getMenusByPlan(user.subscription?.planId);

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    token_type: "Bearer",
    expires_in: expiresIn,
    user: {
      id: user.id,
      email: user.email,
      fullName: `${user.firstName} ${user.lastName}`,
      avatar: user.avatar,
      emailVerified: user.emailVerified,
    },
    subscription: user.subscription
      ? {
          status: user.subscription.status,
          plan: user.subscription.plan.name,
          endDate: user.subscription.endDate,
        }
      : null,
    menu,
  };
}