// =====================================================
// services/session.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import { randomUUID } from "crypto";

const SESSION_EXPIRY_DAYS = 7;

// =====================================================
// CREAR SESIÓN
// =====================================================
export async function createSession(data: {
  userId: string;
  ipAddress?: string;
  userAgent?: string;
  deviceType?: string;
}) {
  return database.session.create({
    data: {
      userId: data.userId,
      token: randomUUID(),
      expiresAt: new Date(Date.now() + SESSION_EXPIRY_DAYS * 24 * 60 * 60 * 1000),
      ipAddress: data.ipAddress,
      userAgent: data.userAgent,
      deviceType: data.deviceType,
      isValid: true,
    },
  });
}

// =====================================================
// BUSCAR SESIÓN
// =====================================================
export async function findSessionById(id: string) {
  return database.session.findUnique({
    where: { id },
    include: {
      user: {
        include: {
          subscription: { include: { plan: true } },
        },
      },
    },
  });
}

export async function findSessionByToken(token: string) {
  return database.session.findUnique({
    where: { token },
    include: { user: true },
  });
}

// =====================================================
// VALIDAR SESIÓN
// =====================================================
export async function isSessionValid(sessionId: string): Promise<boolean> {
  const session = await database.session.findUnique({
    where: { id: sessionId },
    select: { isValid: true, expiresAt: true },
  });

  if (!session) return false;
  if (!session.isValid) return false;
  if (new Date() > session.expiresAt) return false;

  return true;
}

// =====================================================
// OBTENER SESIONES ACTIVAS
// =====================================================
export async function getActiveSessions(userId: string) {
  return database.session.findMany({
    where: {
      userId,
      isValid: true,
      expiresAt: { gt: new Date() },
    },
    select: {
      id: true,
      ipAddress: true,
      userAgent: true,
      deviceType: true,
      createdAt: true,
      expiresAt: true,
    },
    orderBy: { createdAt: "desc" },
  });
}

// =====================================================
// INVALIDAR SESIÓN
// =====================================================
export async function invalidateSession(sessionId: string) {
  return database.session.update({
    where: { id: sessionId },
    data: { isValid: false },
  });
}

export async function invalidateAllSessions(userId: string) {
  return database.session.updateMany({
    where: { userId, isValid: true },
    data: { isValid: false },
  });
}

export async function invalidateOtherSessions(
  userId: string,
  currentSessionId: string
) {
  return database.session.updateMany({
    where: {
      userId,
      isValid: true,
      NOT: { id: currentSessionId },
    },
    data: { isValid: false },
  });
}

// =====================================================
// LIMPIAR SESIONES EXPIRADAS
// =====================================================
export async function cleanExpiredSessions() {
  return database.session.deleteMany({
    where: {
      OR: [
        { expiresAt: { lt: new Date() } },
        { isValid: false },
      ],
    },
  });
}

// =====================================================
// EXTENDER SESIÓN
// =====================================================
export async function extendSession(sessionId: string) {
  return database.session.update({
    where: { id: sessionId },
    data: {
      expiresAt: new Date(Date.now() + SESSION_EXPIRY_DAYS * 24 * 60 * 60 * 1000),
    },
  });
}