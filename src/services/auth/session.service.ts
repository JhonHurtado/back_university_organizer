// =====================================================
// services/session.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import {
  ActiveSessionInfo,
  CreateSessionData,
  SessionWithUser,
} from "@/types/schemas/session/session.schema";
import { randomUUID } from "crypto";
import type { Session, User } from "@prisma/client";

// =====================================================
// CONSTANTS
// =====================================================
const SESSION_EXPIRY_DAYS = 7;
const SESSION_EXPIRY_MS = SESSION_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

// =====================================================
// SESSION SERVICE
// =====================================================
export class SessionService {
  /**
   * Crea una nueva sesión para un usuario
   *
   * @param data - Datos de la sesión a crear
   * @returns Promesa con la sesión creada
   * @throws Error si falla la creación en base de datos
   */
  async createSession(data: CreateSessionData): Promise<Session> {
    try {
      return await database.session.create({
        data: {
          userId: data.userId,
          token: randomUUID(),
          expiresAt: new Date(Date.now() + SESSION_EXPIRY_MS),
          ipAddress: data.ipAddress,
          userAgent: data.userAgent,
          deviceType: data.deviceType,
          isValid: true,
        },
      });
    } catch (error) {
      console.error("SessionService.createSession error:", error);
      throw new Error("Failed to create session");
    }
  }

  /**
   * Busca una sesión por su ID incluyendo información del usuario
   *
   * @param id - ID de la sesión
   * @returns Promesa con la sesión y usuario o null si no existe
   */
  async findSessionById(id: string): Promise<SessionWithUser | null> {
    try {
      return await database.session.findUnique({
        where: { id },
        include: {
          user: {
            include: {
              subscription: { include: { plan: true } },
            },
          },
        },
      });
    } catch (error) {
      console.error("SessionService.findSessionById error:", error);
      return null;
    }
  }

  /**
   * Busca una sesión por su token
   *
   * @param token - Token de la sesión
   * @returns Promesa con la sesión y usuario o null si no existe
   */
  async findSessionByToken(
    token: string
  ): Promise<(Session & { user: User }) | null> {
    try {
      return await database.session.findUnique({
        where: { token },
        include: { user: true },
      });
    } catch (error) {
      console.error("SessionService.findSessionByToken error:", error);
      return null;
    }
  }

  /**
   * Valida si una sesión está activa y no ha expirado
   *
   * @param sessionId - ID de la sesión a validar
   * @returns Promesa con true si la sesión es válida, false en caso contrario
   */
  async isSessionValid(sessionId: string): Promise<boolean> {
    try {
      const session = await database.session.findUnique({
        where: { id: sessionId },
        select: { isValid: true, expiresAt: true },
      });

      if (!session) return false;
      if (!session.isValid) return false;
      if (new Date() > session.expiresAt) return false;

      return true;
    } catch (error) {
      console.error("SessionService.isSessionValid error:", error);
      return false;
    }
  }

  /**
   * Obtiene todas las sesiones activas de un usuario
   *
   * @param userId - ID del usuario
   * @returns Promesa con array de sesiones activas
   */
  async getActiveSessions(userId: string): Promise<ActiveSessionInfo[]> {
    try {
      return await database.session.findMany({
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
    } catch (error) {
      console.error("SessionService.getActiveSessions error:", error);
      return [];
    }
  }

  /**
   * Invalida una sesión específica
   *
   * @param sessionId - ID de la sesión a invalidar
   * @returns Promesa con la sesión actualizada
   * @throws Error si falla la actualización
   */
  async invalidateSession(sessionId: string): Promise<Session> {
    try {
      return await database.session.update({
        where: { id: sessionId },
        data: { isValid: false },
      });
    } catch (error) {
      console.error("SessionService.invalidateSession error:", error);
      throw new Error("Failed to invalidate session");
    }
  }

  /**
   * Invalida todas las sesiones activas de un usuario
   *
   * @param userId - ID del usuario
   * @returns Promesa con el número de sesiones invalidadas
   * @throws Error si falla la actualización
   */
  async invalidateAllSessions(userId: string): Promise<number> {
    try {
      const result = await database.session.updateMany({
        where: { userId, isValid: true },
        data: { isValid: false },
      });
      return result.count;
    } catch (error) {
      console.error("SessionService.invalidateAllSessions error:", error);
      throw new Error("Failed to invalidate all sessions");
    }
  }

  /**
   * Invalida todas las sesiones de un usuario excepto la actual
   *
   * @param userId - ID del usuario
   * @param currentSessionId - ID de la sesión actual a mantener
   * @returns Promesa con el número de sesiones invalidadas
   * @throws Error si falla la actualización
   */
  async invalidateOtherSessions(
    userId: string,
    currentSessionId: string
  ): Promise<number> {
    try {
      const result = await database.session.updateMany({
        where: {
          userId,
          isValid: true,
          NOT: { id: currentSessionId },
        },
        data: { isValid: false },
      });
      return result.count;
    } catch (error) {
      console.error("SessionService.invalidateOtherSessions error:", error);
      throw new Error("Failed to invalidate other sessions");
    }
  }

  /**
   * Elimina sesiones expiradas o inválidas de la base de datos
   * Útil para ejecutar como tarea programada de limpieza
   *
   * @returns Promesa con el número de sesiones eliminadas
   */
  async cleanExpiredSessions(): Promise<number> {
    try {
      const result = await database.session.deleteMany({
        where: {
          OR: [{ expiresAt: { lt: new Date() } }, { isValid: false }],
        },
      });
      return result.count;
    } catch (error) {
      console.error("SessionService.cleanExpiredSessions error:", error);
      return 0;
    }
  }

  /**
   * Extiende la duración de una sesión activa
   *
   * @param sessionId - ID de la sesión a extender
   * @returns Promesa con la sesión actualizada
   * @throws Error si falla la actualización
   */
  async extendSession(sessionId: string): Promise<Session> {
    try {
      return await database.session.update({
        where: { id: sessionId },
        data: {
          expiresAt: new Date(Date.now() + SESSION_EXPIRY_MS),
        },
      });
    } catch (error) {
      console.error("SessionService.extendSession error:", error);
      throw new Error("Failed to extend session");
    }
  }

  /**
   * Cuenta el número total de sesiones activas de un usuario
   *
   * @param userId - ID del usuario
   * @returns Promesa con el número de sesiones activas
   */
  async countActiveSessions(userId: string): Promise<number> {
    try {
      return await database.session.count({
        where: {
          userId,
          isValid: true,
          expiresAt: { gt: new Date() },
        },
      });
    } catch (error) {
      console.error("SessionService.countActiveSessions error:", error);
      return 0;
    }
  }

  /**
   * Verifica si una sesión pertenece a un usuario específico
   *
   * @param sessionId - ID de la sesión
   * @param userId - ID del usuario
   * @returns Promesa con true si la sesión pertenece al usuario
   */
  async sessionBelongsToUser(
    sessionId: string,
    userId: string
  ): Promise<boolean> {
    try {
      const session = await database.session.findUnique({
        where: { id: sessionId },
        select: { userId: true },
      });
      return session?.userId === userId;
    } catch (error) {
      console.error("SessionService.sessionBelongsToUser error:", error);
      return false;
    }
  }
}

// =====================================================
// EXPORT SINGLETON INSTANCE
// =====================================================
export const sessionService = new SessionService();
