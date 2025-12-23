// =====================================================
// services/activityLogs/activityLog.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateActivityLogInput,
  ActivityLogQueryInput,
} from "@/types/schemas/activityLogs/activityLog.schemas";
import type { ActivityLog } from "@prisma/client";

// =====================================================
// ACTIVITY LOG SERVICE
// =====================================================
class ActivityLogService {
  // =====================================================
  // CREATE ACTIVITY LOG
  // =====================================================
  async create(data: CreateActivityLogInput): Promise<ActivityLog> {
    const log = await database.activityLog.create({
      data: {
        ...data,
        oldValues: data.oldValues as any,
        newValues: data.newValues as any,
      },
    });

    return log;
  }

  // =====================================================
  // GET LOGS BY USER
  // =====================================================
  async getByUser(
    userId: string,
    filters?: ActivityLogQueryInput
  ): Promise<{
    logs: ActivityLog[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      userId,
      state: "A",
      ...(filters?.action && { action: filters.action }),
      ...(filters?.entity && { entity: filters.entity }),
      ...(filters?.entityId && { entityId: filters.entityId }),
    };

    // Filtros de fecha
    if (filters?.dateFrom || filters?.dateTo) {
      where.createdAt = {};
      if (filters.dateFrom) {
        where.createdAt.gte = filters.dateFrom;
      }
      if (filters.dateTo) {
        where.createdAt.lte = filters.dateTo;
      }
    }

    const sortBy = filters?.sortBy || "createdAt";
    const sortOrder = filters?.sortOrder || "desc";

    const [logs, total] = await Promise.all([
      database.activityLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          [sortBy]: sortOrder,
        },
        include: {
          user: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
            },
          },
        },
      }),
      database.activityLog.count({ where }),
    ]);

    return {
      logs,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  // =====================================================
  // GET ALL LOGS (ADMIN)
  // =====================================================
  async getAll(
    filters?: ActivityLogQueryInput
  ): Promise<{
    logs: ActivityLog[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      state: "A",
      ...(filters?.userId && { userId: filters.userId }),
      ...(filters?.action && { action: filters.action }),
      ...(filters?.entity && { entity: filters.entity }),
      ...(filters?.entityId && { entityId: filters.entityId }),
    };

    // Filtros de fecha
    if (filters?.dateFrom || filters?.dateTo) {
      where.createdAt = {};
      if (filters.dateFrom) {
        where.createdAt.gte = filters.dateFrom;
      }
      if (filters.dateTo) {
        where.createdAt.lte = filters.dateTo;
      }
    }

    const sortBy = filters?.sortBy || "createdAt";
    const sortOrder = filters?.sortOrder || "desc";

    const [logs, total] = await Promise.all([
      database.activityLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          [sortBy]: sortOrder,
        },
        include: {
          user: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
            },
          },
        },
      }),
      database.activityLog.count({ where }),
    ]);

    return {
      logs,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  // =====================================================
  // GET LOG BY ID
  // =====================================================
  async getById(id: string, userId?: string): Promise<ActivityLog | null> {
    const where: any = {
      id,
      state: "A",
    };

    // Si se proporciona userId, filtrar por él (para usuarios normales)
    if (userId) {
      where.userId = userId;
    }

    const log = await database.activityLog.findFirst({
      where,
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return log;
  }

  // =====================================================
  // GET ACTIVITY BY ENTITY
  // =====================================================
  async getByEntity(
    entity: string,
    entityId: string,
    userId?: string
  ): Promise<ActivityLog[]> {
    const where: any = {
      entity,
      entityId,
      state: "A",
    };

    if (userId) {
      where.userId = userId;
    }

    const logs = await database.activityLog.findMany({
      where,
      orderBy: {
        createdAt: "desc",
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return logs;
  }

  // =====================================================
  // DELETE OLD LOGS
  // =====================================================
  async deleteOldLogs(daysOld: number = 90): Promise<{ count: number }> {
    const dateThreshold = new Date();
    dateThreshold.setDate(dateThreshold.getDate() - daysOld);

    const result = await database.activityLog.updateMany({
      where: {
        createdAt: { lt: dateThreshold },
        state: "A",
      },
      data: { state: "I" },
    });

    return { count: result.count };
  }

  // =====================================================
  // GET USER ACTIVITY STATS
  // =====================================================
  async getUserStats(userId: string): Promise<{
    totalActions: number;
    actionsByType: Record<string, number>;
    recentActivity: ActivityLog[];
  }> {
    const [total, logs] = await Promise.all([
      database.activityLog.count({
        where: { userId, state: "A" },
      }),
      database.activityLog.findMany({
        where: { userId, state: "A" },
        orderBy: { createdAt: "desc" },
        take: 10,
        include: {
          user: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
            },
          },
        },
      }),
    ]);

    // Agrupar por tipo de acción
    const actionsByType: Record<string, number> = {};
    const allLogs = await database.activityLog.findMany({
      where: { userId, state: "A" },
      select: { action: true },
    });

    allLogs.forEach((log) => {
      actionsByType[log.action] = (actionsByType[log.action] || 0) + 1;
    });

    return {
      totalActions: total,
      actionsByType,
      recentActivity: logs,
    };
  }

  // =====================================================
  // HELPER: LOG USER ACTION
  // =====================================================
  async logUserAction(
    userId: string,
    action: string,
    entity: string,
    entityId?: string,
    oldValues?: Record<string, any>,
    newValues?: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: action as any,
      entity: entity as any,
      entityId,
      oldValues,
      newValues,
      ipAddress,
      userAgent,
    });
  }

  // =====================================================
  // HELPER: LOG SYSTEM ACTION (sin usuario)
  // =====================================================
  async logSystemAction(
    action: string,
    entity: string,
    entityId?: string,
    newValues?: Record<string, any>
  ): Promise<ActivityLog> {
    return this.create({
      userId: null,
      action: action as any,
      entity: entity as any,
      entityId,
      newValues,
    });
  }

  // =====================================================
  // HELPER: LOG LOGIN
  // =====================================================
  async logLogin(
    userId: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: "LOGIN",
      entity: "SESSION",
      ipAddress,
      userAgent,
    });
  }

  // =====================================================
  // HELPER: LOG LOGOUT
  // =====================================================
  async logLogout(
    userId: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: "LOGOUT",
      entity: "SESSION",
      ipAddress,
      userAgent,
    });
  }

  // =====================================================
  // HELPER: LOG CREATE
  // =====================================================
  async logCreate(
    userId: string,
    entity: string,
    entityId: string,
    newValues: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: "CREATE",
      entity: entity as any,
      entityId,
      newValues,
      ipAddress,
      userAgent,
    });
  }

  // =====================================================
  // HELPER: LOG UPDATE
  // =====================================================
  async logUpdate(
    userId: string,
    entity: string,
    entityId: string,
    oldValues: Record<string, any>,
    newValues: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: "UPDATE",
      entity: entity as any,
      entityId,
      oldValues,
      newValues,
      ipAddress,
      userAgent,
    });
  }

  // =====================================================
  // HELPER: LOG DELETE
  // =====================================================
  async logDelete(
    userId: string,
    entity: string,
    entityId: string,
    oldValues: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ActivityLog> {
    return this.create({
      userId,
      action: "DELETE",
      entity: entity as any,
      entityId,
      oldValues,
      ipAddress,
      userAgent,
    });
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const activityLogService = new ActivityLogService();
