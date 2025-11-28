// =====================================================
// services/account.service.ts
// =====================================================

import database from "@/lib/prisma/prisma";

// =====================================================
// CREAR CUENTA OAUTH
// =====================================================
export async function createAccount(data: {
  userId: string;
  provider: string;
  providerAccountId: string;
  type?: string;
  accessToken?: string;
  refreshToken?: string;
  expiresAt?: number;
  tokenType?: string;
  scope?: string;
  idToken?: string;
}) {
  return database.account.create({
    data: {
      userId: data.userId,
      provider: data.provider,
      providerAccountId: data.providerAccountId,
      type: data.type || "oauth",
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      expiresAt: data.expiresAt,
      tokenType: data.tokenType,
      scope: data.scope,
      idToken: data.idToken,
    },
  });
}

// =====================================================
// BUSCAR CUENTA
// =====================================================
export async function findAccountByProvider(
  provider: string,
  providerAccountId: string
) {
  return database.account.findUnique({
    where: {
      provider_providerAccountId: {
        provider,
        providerAccountId,
      },
    },
    include: {
      user: {
        include: {
          subscription: { include: { plan: true } },
          preferences: true,
        },
      },
    },
  });
}

export async function findAccountsByUserId(userId: string) {
  return database.account.findMany({
    where: { userId },
    select: {
      id: true,
      provider: true,
      providerAccountId: true,
      type: true,
      createdAt: true,
    },
  });
}

// =====================================================
// ACTUALIZAR TOKENS
// =====================================================
export async function updateAccountTokens(
  id: string,
  data: {
    accessToken?: string;
    refreshToken?: string;
    expiresAt?: number;
  }
) {
  return database.account.update({
    where: { id },
    data,
  });
}

// =====================================================
// ELIMINAR CUENTA (desvincular proveedor)
// =====================================================
export async function deleteAccount(id: string) {
  return database.account.delete({
    where: { id },
  });
}

export async function deleteAccountByProvider(
  userId: string,
  provider: string
) {
  return database.account.deleteMany({
    where: { userId, provider },
  });
}

// =====================================================
// VERIFICAR SI TIENE OTRAS FORMAS DE LOGIN
// =====================================================
export async function canUnlinkProvider(
  userId: string,
  provider: string
): Promise<boolean> {
  const user = await database.user.findUnique({
    where: { id: userId },
    select: {
      password: true,
      accounts: { select: { provider: true } },
    },
  });

  if (!user) return false;

  // Tiene password, puede desvincular
  if (user.password) return true;

  // Tiene otras cuentas OAuth
  const otherAccounts = user.accounts.filter(
    (a: any) => a.provider !== provider
  );
  return otherAccounts.length > 0;
}
