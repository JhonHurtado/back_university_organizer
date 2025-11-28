// =====================================================
// services/verificationToken.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import { randomUUID } from "crypto";
import { TokenType } from "generated/prisma/enums";

const TOKEN_EXPIRY = {
  EMAIL_VERIFICATION: 24 * 60 * 60 * 1000, // 24 horas
  PASSWORD_RESET: 60 * 60 * 1000, // 1 hora
  TWO_FACTOR: 10 * 60 * 1000, // 10 minutos
};

// =====================================================
// CREAR TOKEN
// =====================================================
export async function createVerificationToken(
  userId: string,
  type: TokenType
) {
  // Invalidar tokens anteriores del mismo tipo
  await database.verificationToken.updateMany({
    where: { userId, type, usedAt: null },
    data: { usedAt: new Date() },
  });

  const token = randomUUID();
  const expiresAt = new Date(Date.now() + TOKEN_EXPIRY[type]);

  return database.verificationToken.create({
    data: {
      userId,
      token,
      type,
      expiresAt,
    },
  });
}

// =====================================================
// VERIFICAR TOKEN
// =====================================================
export async function verifyToken(token: string, type: TokenType) {
  const record = await database.verificationToken.findFirst({
    where: {
      token,
      type,
      usedAt: null,
      expiresAt: { gt: new Date() },
    },
    include: { user: true },
  });

  return record;
}

// =====================================================
// USAR TOKEN (marcar como usado)
// =====================================================
export async function useToken(tokenId: string) {
  return database.verificationToken.update({
    where: { id: tokenId },
    data: { usedAt: new Date() },
  });
}

// =====================================================
// INVALIDAR TOKENS
// =====================================================
export async function invalidateTokens(userId: string, type: TokenType) {
  return database.verificationToken.updateMany({
    where: { userId, type, usedAt: null },
    data: { usedAt: new Date() },
  });
}

// =====================================================
// LIMPIAR TOKENS EXPIRADOS
// =====================================================
export async function cleanExpiredTokens() {
  return database.verificationToken.deleteMany({
    where: {
      OR: [
        { expiresAt: { lt: new Date() } },
        { usedAt: { not: null } },
      ],
    },
  });
}

// =====================================================
// HELPERS
// =====================================================
export async function createEmailVerificationToken(userId: string) {
  return createVerificationToken(userId, "EMAIL_VERIFICATION");
}

export async function createPasswordResetToken(userId: string) {
  return createVerificationToken(userId, "PASSWORD_RESET");
}

export async function createTwoFactorToken(userId: string) {
  return createVerificationToken(userId, "TWO_FACTOR");
}