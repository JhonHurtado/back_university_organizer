// =====================================================
// middleware/activityLog/activityLog.middleware.ts
// =====================================================
import type { Request, Response, NextFunction } from "express";
import { activityLogService } from "@/services/activityLogs/activityLog.service";

// =====================================================
// TYPES
// =====================================================
interface ActivityLogConfig {
  action: string;
  entity: string;
  getEntityId?: (req: Request, res: Response) => string | undefined;
  captureBody?: boolean;
  captureOldValues?: boolean;
}

// =====================================================
// HELPER: Extract IP Address
// =====================================================
function getIpAddress(req: Request): string | undefined {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string") {
    return forwarded.split(",")[0].trim();
  }
  return req.socket.remoteAddress;
}

// =====================================================
// HELPER: Extract User Agent
// =====================================================
function getUserAgent(req: Request): string | undefined {
  return req.headers["user-agent"];
}

// =====================================================
// HELPER: Map HTTP Method to Action
// =====================================================
function mapMethodToAction(method: string): string {
  const methodMap: Record<string, string> = {
    POST: "CREATE",
    PUT: "UPDATE",
    PATCH: "UPDATE",
    DELETE: "DELETE",
    GET: "VIEW",
  };
  return methodMap[method] || "OTHER";
}

// =====================================================
// HELPER: Extract Entity from URL
// =====================================================
function extractEntityFromUrl(url: string): string {
  // Remover query params
  const cleanUrl = url.split("?")[0];

  // Extraer el primer segmento después de /api/v1/
  const segments = cleanUrl.split("/").filter(Boolean);

  // El tercer segmento suele ser la entidad (después de api/v1)
  if (segments.length >= 3) {
    const entity = segments[2].toUpperCase();

    // Mapear nombres de rutas a entidades
    const entityMap: Record<string, string> = {
      "CAREERS": "CAREER",
      "SUBJECTS": "SUBJECT",
      "SEMESTERS": "SEMESTER",
      "ENROLLMENTS": "ENROLLMENT",
      "GRADES": "GRADE",
      "SCHEDULES": "SCHEDULE",
      "NOTIFICATIONS": "NOTIFICATION",
      "SUBSCRIPTIONS": "SUBSCRIPTION",
      "PAYMENTS": "PAYMENT",
      "INVOICES": "INVOICE",
      "PLANS": "PLAN",
      "MENUS": "MENU",
      "PROFESSORS": "PROFESSOR",
      "PREFERENCES": "PREFERENCE",
      "USERS": "USER",
      "CLIENTS": "API_CLIENT",
      "ACADEMIC": "SUBJECT", // Ruta académica maneja subjects
      "ACTIVITY-LOGS": "OTHER", // No loguear logs de logs
    };

    return entityMap[entity] || "OTHER";
  }

  return "OTHER";
}

// =====================================================
// HELPER: Extract Entity ID from URL
// =====================================================
function extractEntityIdFromUrl(req: Request): string | undefined {
  // Buscar el parámetro :id en los params
  if (req.params.id) {
    return req.params.id;
  }

  // Si hay otros parámetros de ID
  const idParams = Object.keys(req.params).filter(key =>
    key.toLowerCase().includes("id") && req.params[key]
  );

  if (idParams.length > 0) {
    return req.params[idParams[0]];
  }

  return undefined;
}

// =====================================================
// MIDDLEWARE: Auto Log Activity
// =====================================================
export function autoLogActivity() {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Solo loguear si hay usuario autenticado
    if (!req.user?.id) {
      return next();
    }

    // No loguear GETs por defecto (demasiados logs)
    if (req.method === "GET") {
      return next();
    }

    // No loguear rutas de activity-logs
    if (req.url.includes("/activity-logs")) {
      return next();
    }

    // Capturar datos antes de la ejecución
    const userId = req.user.id;
    const action = mapMethodToAction(req.method);
    const entity = extractEntityFromUrl(req.url);
    const ipAddress = getIpAddress(req);
    const userAgent = getUserAgent(req);

    // Capturar el body original para CREATE/UPDATE
    const newValues = ["POST", "PUT", "PATCH"].includes(req.method)
      ? { ...req.body }
      : undefined;

    // Hook para capturar el entityId después de la respuesta
    const originalSend = res.send;
    res.send = function (data: any): Response {
      // Restaurar el método original
      res.send = originalSend;

      // Si la respuesta fue exitosa (2xx), loguear la actividad
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Intentar extraer entityId de los params o del response body
        let entityId = extractEntityIdFromUrl(req);

        // Si no hay entityId en params, intentar extraerlo del response
        if (!entityId && data) {
          try {
            const responseData = typeof data === "string" ? JSON.parse(data) : data;
            entityId = responseData?.data?.id || responseData?.id;
          } catch (e) {
            // Ignorar errores de parsing
          }
        }

        // Loguear de forma asíncrona sin bloquear la respuesta
        activityLogService.create({
          userId,
          action: action as any,
          entity: entity as any,
          entityId,
          newValues: newValues as any,
          ipAddress,
          userAgent,
        }).catch(error => {
          console.error("Error logging activity:", error);
        });
      }

      // Enviar la respuesta original
      return originalSend.call(this, data);
    };

    next();
  };
}

// =====================================================
// MIDDLEWARE: Log Specific Action
// =====================================================
export function logActivity(config: ActivityLogConfig) {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user?.id) {
      return next();
    }

    const userId = req.user.id;
    const ipAddress = getIpAddress(req);
    const userAgent = getUserAgent(req);

    // Capturar valores según configuración
    const newValues = config.captureBody ? { ...req.body } : undefined;

    // Hook para capturar después de la respuesta
    const originalSend = res.send;
    res.send = function (data: any): Response {
      res.send = originalSend;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Obtener entityId
        const entityId = config.getEntityId
          ? config.getEntityId(req, res)
          : extractEntityIdFromUrl(req);

        // Loguear de forma asíncrona
        activityLogService.create({
          userId,
          action: config.action as any,
          entity: config.entity as any,
          entityId,
          newValues: newValues as any,
          ipAddress,
          userAgent,
        }).catch(error => {
          console.error("Error logging activity:", error);
        });
      }

      return originalSend.call(this, data);
    };

    next();
  };
}

// =====================================================
// MIDDLEWARE: Log Login
// =====================================================
export function logLogin() {
  return async (req: Request, res: Response, next: NextFunction) => {
    const originalSend = res.send;
    res.send = function (data: any): Response {
      res.send = originalSend;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          const responseData = typeof data === "string" ? JSON.parse(data) : data;
          const userId = responseData?.data?.user?.id;

          if (userId) {
            const ipAddress = getIpAddress(req);
            const userAgent = getUserAgent(req);

            activityLogService.logLogin(userId, ipAddress, userAgent).catch(error => {
              console.error("Error logging login:", error);
            });
          }
        } catch (e) {
          // Ignorar errores de parsing
        }
      }

      return originalSend.call(this, data);
    };

    next();
  };
}

// =====================================================
// MIDDLEWARE: Log Logout
// =====================================================
export function logLogout() {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user?.id) {
      return next();
    }

    const userId = req.user.id;
    const ipAddress = getIpAddress(req);
    const userAgent = getUserAgent(req);

    const originalSend = res.send;
    res.send = function (data: any): Response {
      res.send = originalSend;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        activityLogService.logLogout(userId, ipAddress, userAgent).catch(error => {
          console.error("Error logging logout:", error);
        });
      }

      return originalSend.call(this, data);
    };

    next();
  };
}
