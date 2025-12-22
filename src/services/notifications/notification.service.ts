// =====================================================
// services/notifications/notification.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreateNotificationInput,
  UpdateNotificationInput,
  NotificationQueryInput,
} from "@/types/schemas/notifications/notification.schemas";
import type { Notification } from "generated/prisma/client";

// =====================================================
// NOTIFICATION SERVICE
// =====================================================
class NotificationService {
  // =====================================================
  // CREATE NOTIFICATION
  // =====================================================
  async create(data: CreateNotificationInput): Promise<Notification> {
    // Verificar que el usuario existe
    const user = await database.user.findUnique({
      where: { id: data.userId },
    });

    if (!user) {
      throw new Error("USER_NOT_FOUND");
    }

    const notification = await database.notification.create({
      data: {
        ...data,
        metadata: data.metadata as any,
      },
    });

    return notification;
  }

  // =====================================================
  // GET NOTIFICATIONS BY USER
  // =====================================================
  async getByUser(
    userId: string,
    filters?: NotificationQueryInput
  ): Promise<{
    notifications: Notification[];
    total: number;
    unread: number;
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
      ...(filters?.type && { type: filters.type }),
      ...(filters?.category && { category: filters.category }),
      ...(filters?.isRead !== undefined && { isRead: filters.isRead }),
    };

    // No mostrar notificaciones expiradas
    where.OR = [
      { expiresAt: null },
      { expiresAt: { gt: new Date() } },
    ];

    const [notifications, total, unread] = await Promise.all([
      database.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          createdAt: "desc",
        },
      }),
      database.notification.count({ where }),
      database.notification.count({
        where: {
          userId,
          isRead: false,
          state: "A",
          OR: [
            { expiresAt: null },
            { expiresAt: { gt: new Date() } },
          ],
        },
      }),
    ]);

    return {
      notifications,
      total,
      unread,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  // =====================================================
  // GET NOTIFICATION BY ID
  // =====================================================
  async getById(id: string, userId: string): Promise<Notification | null> {
    const notification = await database.notification.findFirst({
      where: {
        id,
        userId,
        state: "A",
      },
    });

    return notification;
  }

  // =====================================================
  // UPDATE NOTIFICATION
  // =====================================================
  async update(
    id: string,
    userId: string,
    data: UpdateNotificationInput
  ): Promise<Notification> {
    const notification = await database.notification.findFirst({
      where: {
        id,
        userId,
        state: "A",
      },
    });

    if (!notification) {
      throw new Error("NOT_FOUND");
    }

    const updateData: any = { ...data };
    if (data.metadata !== undefined) {
      updateData.metadata = data.metadata as any;
    }

    const updated = await database.notification.update({
      where: { id },
      data: updateData,
    });

    return updated;
  }

  // =====================================================
  // MARK AS READ
  // =====================================================
  async markAsRead(id: string, userId: string): Promise<Notification> {
    const notification = await database.notification.findFirst({
      where: {
        id,
        userId,
        state: "A",
      },
    });

    if (!notification) {
      throw new Error("NOT_FOUND");
    }

    const updated = await database.notification.update({
      where: { id },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return updated;
  }

  // =====================================================
  // MARK ALL AS READ
  // =====================================================
  async markAllAsRead(userId: string): Promise<{ count: number }> {
    const result = await database.notification.updateMany({
      where: {
        userId,
        isRead: false,
        state: "A",
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return { count: result.count };
  }

  // =====================================================
  // DELETE NOTIFICATION
  // =====================================================
  async delete(id: string, userId: string): Promise<void> {
    const notification = await database.notification.findFirst({
      where: {
        id,
        userId,
        state: "A",
      },
    });

    if (!notification) {
      throw new Error("NOT_FOUND");
    }

    await database.notification.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // DELETE ALL READ NOTIFICATIONS
  // =====================================================
  async deleteAllRead(userId: string): Promise<{ count: number }> {
    const result = await database.notification.updateMany({
      where: {
        userId,
        isRead: true,
        state: "A",
      },
      data: { state: "I" },
    });

    return { count: result.count };
  }

  // =====================================================
  // GET UNREAD COUNT
  // =====================================================
  async getUnreadCount(userId: string): Promise<number> {
    const count = await database.notification.count({
      where: {
        userId,
        isRead: false,
        state: "A",
        OR: [
          { expiresAt: null },
          { expiresAt: { gt: new Date() } },
        ],
      },
    });

    return count;
  }

  // =====================================================
  // CLEAN EXPIRED NOTIFICATIONS
  // =====================================================
  async cleanExpired(): Promise<{ count: number }> {
    const result = await database.notification.updateMany({
      where: {
        expiresAt: { lt: new Date() },
        state: "A",
      },
      data: { state: "I" },
    });

    return { count: result.count };
  }

  // =====================================================
  // HELPER: CREATE SYSTEM NOTIFICATION
  // =====================================================
  async createSystemNotification(
    userId: string,
    title: string,
    message: string,
    category: string = "SYSTEM"
  ): Promise<Notification> {
    return this.create({
      userId,
      title,
      message,
      type: "INFO",
      category: category as any,
    });
  }

  // =====================================================
  // HELPER: CREATE GRADE NOTIFICATION
  // =====================================================
  async createGradeNotification(
    userId: string,
    subjectName: string,
    grade: number
  ): Promise<Notification> {
    return this.create({
      userId,
      title: "Nueva calificación registrada",
      message: `Se ha registrado una nueva calificación en ${subjectName}: ${grade}`,
      type: "SUCCESS",
      category: "GRADE",
    });
  }

  // =====================================================
  // HELPER: CREATE SCHEDULE NOTIFICATION
  // =====================================================
  async createScheduleNotification(
    userId: string,
    title: string,
    message: string
  ): Promise<Notification> {
    return this.create({
      userId,
      title,
      message,
      type: "INFO",
      category: "SCHEDULE",
    });
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const notificationService = new NotificationService();
