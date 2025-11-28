// user.service.ts
import database from '@/lib/prisma/prisma';
import bcrypt from 'bcrypt';
import { User } from 'generated/prisma/client';


export class UserService {
  // CREATE
  async create(data: {
    email: string;
    password?: string;
    firstName: string;
    lastName: string;
    phone?: string;
    timezone?: string;
    language?: string;
  }): Promise<User> {
    const hashedPassword = data.password 
      ? await bcrypt.hash(data.password, 10) 
      : null;

    return database.user.create({
      data: {
        ...data,
        password: hashedPassword,
      },
    });
  }

  // READ - By ID
  async findById(id: string): Promise<User | null> {
    return database.user.findUnique({
      where: { id },
      include: {
        subscription: { include: { plan: true } },
        preferences: true,
      },
    });
  }

  // READ - By Email
  async findByEmail(email: string): Promise<User | null> {
    return database.user.findUnique({
      where: { email },
    });
  }

  // READ - All (con paginación)
  async findAll(params: {
    skip?: number;
    take?: number;
    isActive?: boolean;
  }): Promise<User[]> {
    return database.user.findMany({
      where: {
        isActive: params.isActive,
        deletedAt: null,
      },
      skip: params.skip,
      take: params.take,
      orderBy: { createdAt: 'desc' },
    });
  }

  // UPDATE
  async update(id: string, data: Partial<{
    email: string;
    firstName: string;
    lastName: string;
    phone: string;
    avatar: string;
    timezone: string;
    language: string;
    isActive: boolean;
  }>): Promise<User> {
    return database.user.update({
      where: { id },
      data,
    });
  }

  // UPDATE - Password
  async updatePassword(id: string, newPassword: string): Promise<User> {
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    return database.user.update({
      where: { id },
      data: { password: hashedPassword },
    });
  }

  // SOFT DELETE
  async softDelete(id: string): Promise<User> {
    return database.user.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });
  }

  // HARD DELETE
  async delete(id: string): Promise<User> {
    return database.user.delete({
      where: { id },
    });
  }

  // VERIFY PASSWORD
  async verifyPassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  // UPDATE LAST LOGIN
  async updateLastLogin(id: string): Promise<User> {
    return database.user.update({
      where: { id },
      data: { lastLoginAt: new Date() },
    });
  }
}