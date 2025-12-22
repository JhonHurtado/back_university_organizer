// services/users/user.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import bcrypt from "bcrypt";
import type { User, Prisma } from "@prisma/client";

// =====================================================
// TYPES
// =====================================================
export interface CreateUserData {
  email: string;
  password?: string;
  firstName: string;
  lastName: string;
  phone?: string;
  timezone?: string;
  language?: string;
}

export interface UpdateUserData {
  email?: string;
  firstName?: string;
  lastName?: string;
  phone?: string;
  avatar?: string;
  timezone?: string;
  language?: string;
}

export interface UserWithRelations extends User {
  subscription?: {
    id: string;
    status: string;
    plan: {
      id: string;
      name: string;
      slug: string;
    };
  } | null;
  preferences?: {
    id: string;
    darkMode: boolean;
    gradeScale: string;
  } | null;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  isActive?: boolean;
  search?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasMore: boolean;
  };
}

// =====================================================
// CONSTANTS
// =====================================================
const BCRYPT_ROUNDS = 12;
const DEFAULT_PAGE = 1;
const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 100;

// =====================================================
// USER SERVICE
// =====================================================
export class UserService {
  // =====================================================
  // CREATE USER
  // =====================================================
  async create(data: CreateUserData): Promise<User> {
    try {
      const email = data.email.toLowerCase().trim();

      // Verificar si existe
      const exists = await database.user.findUnique({
        where: { email },
      });

      if (exists) {
        throw new Error("EMAIL_EXISTS");
      }

      const hashedPassword = data.password
        ? await bcrypt.hash(data.password, BCRYPT_ROUNDS)
        : null;

      return await database.user.create({
        data: {
          email,
          password: hashedPassword,
          firstName: data.firstName,
          lastName: data.lastName,
          phone: data.phone,
          timezone: data.timezone || "America/Bogota",
          language: data.language || "es",
          preferences: { create: {} },
        },
      });
    } catch (error) {
      console.error("UserService.create error:", error);
      throw error;
    }
  }

  // =====================================================
  // FIND BY ID
  // =====================================================
  async findById(id: string): Promise<UserWithRelations | null> {
    try {
      return await database.user.findUnique({
        where: { id },
        include: {
          subscription: {
            include: {
              plan: {
                select: {
                  id: true,
                  name: true,
                  slug: true,
                  canExportPDF: true,
                  canExportExcel: true,
                  hasAnalytics: true,
                },
              },
            },
          },
          preferences: true,
        },
      });
    } catch (error) {
      console.error("UserService.findById error:", error);
      return null;
    }
  }

  // =====================================================
  // FIND BY EMAIL
  // =====================================================
  async findByEmail(email: string): Promise<User | null> {
    try {
      return await database.user.findUnique({
        where: { email: email.toLowerCase().trim() },
      });
    } catch (error) {
      console.error("UserService.findByEmail error:", error);
      return null;
    }
  }

  // =====================================================
  // FIND BY EMAIL WITH RELATIONS
  // =====================================================
  async findByEmailWithRelations(
    email: string
  ): Promise<UserWithRelations | null> {
    try {
      return await database.user.findUnique({
        where: { email: email.toLowerCase().trim() },
        include: {
          subscription: { include: { plan: true } },
          preferences: true,
        },
      });
    } catch (error) {
      console.error("UserService.findByEmailWithRelations error:", error);
      return null;
    }
  }

  // =====================================================
  // FIND ALL WITH PAGINATION
  // =====================================================
  async findAll(
    params: PaginationParams = {}
  ): Promise<PaginatedResponse<User>> {
    try {
      const page = Math.max(params.page || DEFAULT_PAGE, 1);
      const limit = Math.min(params.limit || DEFAULT_LIMIT, MAX_LIMIT);
      const skip = (page - 1) * limit;

      const where: Prisma.UserWhereInput = {
        deletedAt: null,
        ...(params.isActive !== undefined && { isActive: params.isActive }),
        ...(params.search && {
          OR: [
            { email: { contains: params.search, mode: "insensitive" } },
            { firstName: { contains: params.search, mode: "insensitive" } },
            { lastName: { contains: params.search, mode: "insensitive" } },
          ],
        }),
      };

      const [data, total] = await Promise.all([
        database.user.findMany({
          where,
          skip,
          take: limit,
          orderBy: { createdAt: "desc" },
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            phone: true,
            avatar: true,
            isActive: true,
            emailVerified: true,
            createdAt: true,
            lastLoginAt: true,
          },
        }),
        database.user.count({ where }),
      ]);

      const totalPages = Math.ceil(total / limit);

      return {
        data: data as User[],
        pagination: {
          total,
          page,
          limit,
          totalPages,
          hasMore: page < totalPages,
        },
      };
    } catch (error) {
      console.error("UserService.findAll error:", error);
      throw new Error("Failed to fetch users");
    }
  }

  // =====================================================
  // UPDATE USER
  // =====================================================
  async update(id: string, data: UpdateUserData): Promise<User> {
    try {
      // Si se actualiza email, verificar que no exista
      if (data.email) {
        const email = data.email.toLowerCase().trim();
        const exists = await database.user.findFirst({
          where: {
            email,
            NOT: { id },
          },
        });

        if (exists) {
          throw new Error("EMAIL_EXISTS");
        }

        data.email = email;
      }

      return await database.user.update({
        where: { id },
        data,
      });
    } catch (error) {
      console.error("UserService.update error:", error);
      throw error;
    }
  }

  // =====================================================
  // UPDATE PASSWORD
  // =====================================================
  async updatePassword(id: string, newPassword: string): Promise<User> {
    try {
      const hashedPassword = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);

      return await database.user.update({
        where: { id },
        data: { password: hashedPassword },
      });
    } catch (error) {
      console.error("UserService.updatePassword error:", error);
      throw new Error("Failed to update password");
    }
  }

  // =====================================================
  // VERIFY PASSWORD
  // =====================================================
  async verifyPassword(
    plainPassword: string,
    hashedPassword: string
  ): Promise<boolean> {
    try {
      return await bcrypt.compare(plainPassword, hashedPassword);
    } catch (error) {
      console.error("UserService.verifyPassword error:", error);
      return false;
    }
  }

  // =====================================================
  // VERIFY EMAIL
  // =====================================================
  async verifyEmail(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: {
          emailVerified: true,
          emailVerifiedAt: new Date(),
        },
      });
    } catch (error) {
      console.error("UserService.verifyEmail error:", error);
      throw new Error("Failed to verify email");
    }
  }

  // =====================================================
  // UPDATE LAST LOGIN
  // =====================================================
  async updateLastLogin(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: { lastLoginAt: new Date() },
      });
    } catch (error) {
      console.error("UserService.updateLastLogin error:", error);
      throw new Error("Failed to update last login");
    }
  }

  // =====================================================
  // ACTIVATE / DEACTIVATE
  // =====================================================
  async activate(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: { isActive: true },
      });
    } catch (error) {
      console.error("UserService.activate error:", error);
      throw new Error("Failed to activate user");
    }
  }

  async deactivate(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: { isActive: false },
      });
    } catch (error) {
      console.error("UserService.deactivate error:", error);
      throw new Error("Failed to deactivate user");
    }
  }

  // =====================================================
  // SOFT DELETE
  // =====================================================
  async softDelete(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: {
          deletedAt: new Date(),
          isActive: false,
        },
      });
    } catch (error) {
      console.error("UserService.softDelete error:", error);
      throw new Error("Failed to soft delete user");
    }
  }

  // =====================================================
  // RESTORE
  // =====================================================
  async restore(id: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: {
          deletedAt: null,
          isActive: true,
        },
      });
    } catch (error) {
      console.error("UserService.restore error:", error);
      throw new Error("Failed to restore user");
    }
  }

  // =====================================================
  // HARD DELETE
  // =====================================================
  async delete(id: string): Promise<User> {
    try {
      return await database.user.delete({
        where: { id },
      });
    } catch (error) {
      console.error("UserService.delete error:", error);
      throw new Error("Failed to delete user");
    }
  }

  // =====================================================
  // UPDATE AVATAR
  // =====================================================
  async updateAvatar(id: string, avatarUrl: string): Promise<User> {
    try {
      return await database.user.update({
        where: { id },
        data: { avatar: avatarUrl },
      });
    } catch (error) {
      console.error("UserService.updateAvatar error:", error);
      throw new Error("Failed to update avatar");
    }
  }

  // =====================================================
  // GET USER STATS
  // =====================================================
  async getUserStats(userId: string) {
    try {
      const [careers, notifications] = await Promise.all([
        database.career.count({ where: { userId, deletedAt: null } }),
        database.notification.count({
          where: { userId, isRead: false },
        }),
      ]);

      return {
        totalCareers: careers,
        unreadNotifications: notifications,
      };
    } catch (error) {
      console.error("UserService.getUserStats error:", error);
      return { totalCareers: 0, unreadNotifications: 0 };
    }
  }

  // =====================================================
  // GET ACTIVE USERS COUNT
  // =====================================================
  async getActiveUsersCount(): Promise<number> {
    try {
      return await database.user.count({
        where: {
          isActive: true,
          deletedAt: null,
        },
      });
    } catch (error) {
      console.error("UserService.getActiveUsersCount error:", error);
      return 0;
    }
  }

  // =====================================================
  // SEARCH USERS
  // =====================================================
  async search(query: string, limit: number = 10): Promise<User[]> {
    try {
      return (await database.user.findMany({
        where: {
          deletedAt: null,
          isActive: true,
          OR: [
            { email: { contains: query, mode: "insensitive" } },
            { firstName: { contains: query, mode: "insensitive" } },
            { lastName: { contains: query, mode: "insensitive" } },
          ],
        },
        take: Math.min(limit, MAX_LIMIT),
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          avatar: true,
        },
      })) as User[];
    } catch (error) {
      console.error("UserService.search error:", error);
      return [];
    }
  }

  // =====================================================
  // CHECK EMAIL EXISTS
  // =====================================================
  async emailExists(email: string, excludeUserId?: string): Promise<boolean> {
    try {
      const user = await database.user.findFirst({
        where: {
          email: email.toLowerCase().trim(),
          ...(excludeUserId && { NOT: { id: excludeUserId } }),
        },
      });

      return !!user;
    } catch (error) {
      console.error("UserService.emailExists error:", error);
      return false;
    }
  }

  // =====================================================
  // GET USERS BY IDS
  // =====================================================
  async findByIds(ids: string[]): Promise<User[]> {
    try {
      return await database.user.findMany({
        where: {
          id: { in: ids },
          deletedAt: null,
        },
      });
    } catch (error) {
      console.error("UserService.findByIds error:", error);
      return [];
    }
  }

  // =====================================================
  // GET RECENTLY REGISTERED
  // =====================================================
  async getRecentlyRegistered(limit: number = 10): Promise<User[]> {
    try {
      return (await database.user.findMany({
        where: { deletedAt: null },
        orderBy: { createdAt: "desc" },
        take: Math.min(limit, MAX_LIMIT),
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          avatar: true,
          createdAt: true,
        },
      })) as User[];
    } catch (error) {
      console.error("UserService.getRecentlyRegistered error:", error);
      return [];
    }
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const userService = new UserService();
