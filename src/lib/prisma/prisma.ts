import { Prisma, PrismaClient } from "@prisma/client";

// Extender la interfaz global de Node
declare global {
  var prisma: PrismaClient | undefined;
}

// Configuración de logging según el entorno
const logConfig: Prisma.LogLevel[] =
  process.env.NODE_ENV === "development"
    ? ["query", "info", "warn", "error"]
    : ["error"];

// Crear instancia de Prisma con configuración
const createPrismaClient = (): PrismaClient => {
  const client = new PrismaClient({
    log: logConfig,
    errorFormat: "pretty",
  });

  return client;
};

// Singleton pattern para reutilizar la conexión
export const database = globalThis.prisma ?? createPrismaClient();

// Solo en desarrollo: guardar en global para hot-reload
if (process.env.NODE_ENV !== "production") {
  globalThis.prisma = database;
}

// Desconexión graceful al cerrar la aplicación
export const disconnectDatabase = async (): Promise<void> => {
  try {
    await database.$disconnect();
  } catch (error) {
    console.error("❌ Error al desconectar la base de datos:", error);
    throw error;
  }
};

// Función para verificar la conexión
export const checkDatabaseConnection = async (): Promise<boolean> => {
  try {
    await database.$connect();
    return true;
  } catch (error) {
    console.error("❌ Error al conectar con la base de datos:", error);
    return false;
  }
};

// Exportar tipos útiles de Prisma
export type { Prisma };

// Exportar por defecto
export default database;
