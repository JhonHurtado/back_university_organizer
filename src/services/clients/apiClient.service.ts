// =====================================================
// services/apiClient.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import { randomBytes } from "crypto";
import { ApiClientStatus } from "generated/prisma/enums";

// =====================================================
// CREAR CLIENTE API
// =====================================================
export async function createApiClient(data: {
  name: string;
  description?: string;
  scopes?: string[];
  rateLimit?: number;
}) {
  try {
    const clientId = randomBytes(16).toString("hex");
    const clientSecret = randomBytes(32).toString("hex");

    return await database.apiClient.create({
      data: {
        clientId,
        clientSecret,
        name: data.name,
        description: data.description,
        scopes: data.scopes || [],
        rateLimit: data.rateLimit || 100000,
      },
    });
  } catch (error: any) {
    console.error("❌ Error en createApiClient:", error);
    throw new Error("No fue posible crear el cliente API.");
  }
}

// =====================================================
// BUSCAR CLIENTE POR ID
// =====================================================
export async function findApiClientById(id: string) {
  try {
    return await database.apiClient.findUnique({
      where: { id },
    });
  } catch (error: any) {
    console.error("❌ Error en findApiClientById:", error);
    throw new Error("No fue posible buscar el cliente por ID.");
  }
}

// =====================================================
// BUSCAR CLIENTE POR clientId
// =====================================================
export async function findApiClientByClientId(clientId: string) {
  try {
    return await database.apiClient.findUnique({
      where: { clientId },
    });
  } catch (error: any) {
    console.error("❌ Error en findApiClientByClientId:", error);
    throw new Error("No fue posible buscar el cliente por clientId.");
  }
}

// =====================================================
// VALIDAR CLIENTE
// =====================================================
export async function validateApiClient(
  clientId: string,
  clientSecret: string
): Promise<boolean> {
  try {
    const client = await database.apiClient.findUnique({
      where: { clientId },
      select: { clientSecret: true, status: true },
    });

    if (!client) return false;
    if (client.status !== "ACTIVE") return false;

    return client.clientSecret === clientSecret;
  } catch (error: any) {
    console.error("❌ Error en validateApiClient:", error);
    throw new Error("No fue posible validar el cliente API.");
  }
}

// =====================================================
// ACTUALIZAR CLIENTE
// =====================================================
export async function updateApiClient(
  id: string,
  data: {
    name?: string;
    description?: string;
    scopes?: string[];
    rateLimit?: number;
    status?: ApiClientStatus;
  }
) {
  try {
    return await database.apiClient.update({
      where: { id },
      data,
    });
  } catch (error: any) {
    console.error("❌ Error en updateApiClient:", error);
    throw new Error("No fue posible actualizar el cliente API.");
  }
}

// =====================================================
// REGENERAR SECRET
// =====================================================
export async function regenerateClientSecret(id: string) {
  try {
    const newSecret = randomBytes(32).toString("hex");

    return await database.apiClient.update({
      where: { id },
      data: { clientSecret: newSecret },
    });
  } catch (error: any) {
    console.error("❌ Error en regenerateClientSecret:", error);
    throw new Error("No fue posible regenerar el clientSecret.");
  }
}

// =====================================================
// DESACTIVAR CLIENTE
// =====================================================
export async function deactivateApiClient(id: string) {
  try {
    return await database.apiClient.update({
      where: { id },
      data: { status: "INACTIVE" },
    });
  } catch (error: any) {
    console.error("❌ Error en deactivateApiClient:", error);
    throw new Error("No fue posible desactivar el cliente API.");
  }
}

// =====================================================
// ACTIVAR CLIENTE
// =====================================================
export async function activateApiClient(id: string) {
  try {
    return await database.apiClient.update({
      where: { id },
      data: { status: "ACTIVE" },
    });
  } catch (error: any) {
    console.error("❌ Error en activateApiClient:", error);
    throw new Error("No fue posible activar el cliente API.");
  }
}

// =====================================================
// LISTAR CLIENTES
// =====================================================
export async function listApiClients() {
  try {
    return await database.apiClient.findMany({
      select: {
        id: true,
        clientId: true,
        name: true,
        description: true,
        status: true,
        scopes: true,
        rateLimit: true,
        createdAt: true,
      },
      orderBy: { createdAt: "desc" },
    });
  } catch (error: any) {
    console.error("❌ Error en listApiClients:", error);
    throw new Error("No fue posible listar los clientes API.");
  }
}
