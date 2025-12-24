// =====================================================
// token.service.ts - Servicio Centralizado de JWT
// =====================================================
import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";
import type { JWTPayload } from "@/types/jwt/JWT.types";
import { ENV } from "../config";
import database from "@/lib/prisma/prisma";

// =====================================================
// CONSTANTES Y CONFIGURACIÓN
// =====================================================
const ACCESS_TOKEN_EXPIRY = Number(ENV.TOKEN_EXPIRATION) || 900; // 15 minutos por defecto
const REFRESH_TOKEN_EXPIRY = "7d";
const CLOCK_TOLERANCE = 10; // 10 segundos de tolerancia para evitar problemas de sincronización

// Algoritmos permitidos (solo HS256 para máxima seguridad con secret keys)
const ALLOWED_ALGORITHMS: jwt.Algorithm[] = ["HS256"];

// =====================================================
// INTERFACES
// =====================================================
interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: "Bearer";
}

interface AccessTokenPayload extends JWTPayload {
  sub: string;
  sessionId: string;
  email: string;
  scope: string[];
  jti: string;
  iat: number;
  exp: number;
  iss: string;
  aud: string;
}

interface RefreshTokenPayload {
  sub: string;
  sessionId: string;
  type: "refresh";
  jti: string;
  iat: number;
  exp: number;
  iss: string;
  aud: string;
}

// =====================================================
// GENERAR ACCESS TOKEN
// =====================================================
function generateAccessToken(
  userId: string,
  sessionId: string,
  email: string,
  clientId: string
): { token: string; jti: string; expiresAt: Date } {
  const jti = randomUUID();
  const now = Math.floor(Date.now() / 1000);
  const expiresAt = new Date((now + ACCESS_TOKEN_EXPIRY) * 1000);

  // NO incluir jti en el payload, jwt.sign() lo agregará automáticamente
  const payload: Omit<AccessTokenPayload, "iat" | "exp" | "iss" | "aud" | "jti"> = {
    sub: userId,
    sessionId,
    email,
    scope: ["read", "write"],
  };

  const token = jwt.sign(payload, ENV.JWT_SECRET, {
    algorithm: "HS256",
    expiresIn: ACCESS_TOKEN_EXPIRY,
    issuer: ENV.JWT_ISSUER,
    audience: clientId,
    jwtid: jti, // jti se agrega como opción, no en el payload
  });

  return { token, jti, expiresAt };
}

// =====================================================
// GENERAR REFRESH TOKEN
// =====================================================
function generateRefreshToken(
  userId: string,
  sessionId: string,
  clientId: string
): { token: string; jti: string } {
  const jti = randomUUID();

  // NO incluir jti en el payload, jwt.sign() lo agregará automáticamente
  const payload: Omit<RefreshTokenPayload, "iat" | "exp" | "iss" | "aud" | "jti"> = {
    sub: userId,
    sessionId,
    type: "refresh",
  };

  const token = jwt.sign(payload, ENV.JWT_REFRESH_SECRET, {
    algorithm: "HS256",
    expiresIn: REFRESH_TOKEN_EXPIRY,
    issuer: ENV.JWT_ISSUER,
    audience: clientId,
    jwtid: jti, // jti se agrega como opción, no en el payload
  });

  return { token, jti };
}

// =====================================================
// GENERAR PAR DE TOKENS (ACCESS + REFRESH)
// =====================================================
export async function generateTokens(
  user: any,
  clientId: string
): Promise<TokenPair> {
  try {
    // Generar JTI único para la sesión
    const sessionId = randomUUID();

    // Generar access token
    const { token: accessToken, jti: accessJti, expiresAt } = generateAccessToken(
      user.id,
      sessionId,
      user.email,
      clientId
    );

    // Generar refresh token
    const { token: refreshToken, jti: refreshJti } = generateRefreshToken(
      user.id,
      sessionId,
      clientId
    );

    // Crear sesión en la base de datos (NO guardamos el token completo, solo los JTIs)
    await database.session.create({
      data: {
        id: sessionId,
        userId: user.id,
        token: accessJti, // Guardamos solo el JTI, no el token completo
        refreshToken: refreshJti, // Guardamos solo el JTI del refresh token
        expiresAt,
        isValid: true,
      },
    });

    // Actualizar último login
    await database.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TOKEN_EXPIRY,
      tokenType: "Bearer",
    };
  } catch (error: any) {
    console.error("Error generating tokens:", error.message);
    throw error;
  }
}

// =====================================================
// VERIFICAR ACCESS TOKEN
// =====================================================
export async function verifyAccessToken(
  token: string,
  clientId?: string
): Promise<AccessTokenPayload> {
  try {
    const decoded = jwt.verify(token, ENV.JWT_SECRET, {
      algorithms: ALLOWED_ALGORITHMS,
      issuer: ENV.JWT_ISSUER,
      audience: clientId,
      clockTolerance: CLOCK_TOLERANCE,
    }) as AccessTokenPayload;

    // Verificar que la sesión existe y es válida
    const session = await database.session.findUnique({
      where: { id: decoded.sessionId },
    });

    if (!session || !session.isValid) {
      throw new Error("SESSION_INVALID");
    }

    // Verificar que el JTI coincide (prevenir replay attacks)
    if (session.token !== decoded.jti) {
      throw new Error("TOKEN_JTI_MISMATCH");
    }

    // Verificar que la sesión no ha expirado
    if (new Date() > session.expiresAt) {
      await invalidateSession(session.id);
      throw new Error("SESSION_EXPIRED");
    }

    return decoded;
  } catch (error: any) {
    if (error.name === "TokenExpiredError") {
      throw new Error("TOKEN_EXPIRED");
    }
    if (error.name === "JsonWebTokenError") {
      throw new Error("TOKEN_INVALID");
    }
    throw error;
  }
}

// =====================================================
// REFRESH ACCESS TOKEN
// =====================================================
export async function refreshAccessToken(
  refreshToken: string,
  clientId: string
): Promise<{ accessToken: string; refreshToken: string; user: any; expiresIn: number }> {
  try {
    // Verificar refresh token
    const decoded = jwt.verify(refreshToken, ENV.JWT_REFRESH_SECRET, {
      algorithms: ALLOWED_ALGORITHMS,
      issuer: ENV.JWT_ISSUER,
      audience: clientId,
      clockTolerance: CLOCK_TOLERANCE,
    }) as RefreshTokenPayload;

    // Validar que es un refresh token
    if (decoded.type !== "refresh") {
      throw new Error("INVALID_TOKEN_TYPE");
    }

    // Validar sesión
    const session = await database.session.findUnique({
      where: { id: decoded.sessionId },
      include: {
        user: {
          include: {
            subscription: {
              include: { plan: true },
            },
          },
        },
      },
    });

    if (!session || !session.isValid) {
      throw new Error("SESSION_INVALID");
    }

    // Verificar que el JTI del refresh token coincide
    if (session.refreshToken !== decoded.jti) {
      // Posible ataque de replay - invalidar la sesión
      await invalidateSession(session.id);
      throw new Error("REFRESH_TOKEN_JTI_MISMATCH");
    }

    // Verificar que la sesión no ha expirado
    if (new Date() > session.expiresAt) {
      await invalidateSession(session.id);
      throw new Error("SESSION_EXPIRED");
    }

    const user = session.user;

    // Validar usuario
    if (!user || !user.isActive || user.deletedAt) {
      await invalidateSession(session.id);
      throw new Error("USER_INVALID");
    }

    // ROTACIÓN DE REFRESH TOKEN (best practice de seguridad)
    // Invalidar el refresh token anterior y generar uno nuevo
    const newSessionId = randomUUID();

    // Generar nuevo access token
    const { token: newAccessToken, jti: newAccessJti, expiresAt } = generateAccessToken(
      user.id,
      newSessionId,
      user.email,
      clientId
    );

    // Generar nuevo refresh token
    const { token: newRefreshToken, jti: newRefreshJti } = generateRefreshToken(
      user.id,
      newSessionId,
      clientId
    );

    // Invalidar sesión anterior
    await database.session.update({
      where: { id: session.id },
      data: { isValid: false },
    });

    // Crear nueva sesión
    await database.session.create({
      data: {
        id: newSessionId,
        userId: user.id,
        token: newAccessJti,
        refreshToken: newRefreshJti,
        expiresAt,
        isValid: true,
      },
    });

    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      user,
      expiresIn: ACCESS_TOKEN_EXPIRY,
    };
  } catch (error: any) {
    if (error.name === "TokenExpiredError") {
      throw new Error("REFRESH_TOKEN_EXPIRED");
    }
    if (error.name === "JsonWebTokenError") {
      throw new Error("REFRESH_TOKEN_INVALID");
    }
    throw error;
  }
}

// =====================================================
// INVALIDAR SESIÓN (LOGOUT)
// =====================================================
export async function invalidateSession(sessionId: string): Promise<void> {
  await database.session.update({
    where: { id: sessionId },
    data: { isValid: false },
  });
}

// =====================================================
// INVALIDAR TODAS LAS SESIONES DE UN USUARIO
// =====================================================
export async function invalidateAllSessions(userId: string): Promise<void> {
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
        ...(planId ? [{ planAccess: { some: { planId, canView: true } } }] : []),
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
// CONSTRUIR RESPUESTA DE AUTENTICACIÓN
// =====================================================
export async function buildAuthResponse(user: any, clientId: string) {
  try {
    const { accessToken, refreshToken, expiresIn, tokenType } = await generateTokens(
      user,
      clientId
    );

    const menu = await getMenusByPlan(user.subscription?.planId);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: tokenType,
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
            plan: user.subscription.plan?.name,
            endDate: user.subscription.endDate,
          }
        : null,
      menu,
    };
  } catch (error: any) {
    console.error("buildAuthResponse error:", error);
    throw error;
  }
}
