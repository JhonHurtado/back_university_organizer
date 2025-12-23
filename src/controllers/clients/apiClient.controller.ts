// =====================================================
// apiClient.controller.ts
// =====================================================
import type { Request, Response } from "express";
import * as apiClientService from "../../services/clients/apiClient.service";
import {
  createApiClientSchema,
  updateApiClientSchema,
  apiClientIdSchema,
} from "../../types/schemas/clients/apiClient.schemas";
import { ZodError } from "zod";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";

export async function create(req: Request, res: Response) {
  try {
    const data = createApiClientSchema.parse(req.body);
    const client = await apiClientService.createApiClient(data);

    return sendCreated({
      res,
      message: "Cliente API creado exitosamente",
      data: {
        id: client.id,
        clientId: client.clientId,
        clientSecret: client.clientSecret,
        name: client.name,
        description: client.description,
        scopes: client.scopes,
        rateLimit: client.rateLimit,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({
        res,
        errors,
      });
    }
    return sendServerError({ res, message: "Error al crear cliente",
    });
  }
}

export async function getAll(_req: Request, res: Response) {
  try {
    const clients = await apiClientService.listApiClients();
    return sendSuccess({
      res,
      message: "Clientes obtenidos exitosamente",
      data: clients,
    });
  } catch (error) {
    return sendServerError({ res, message: "Error al obtener clientes",
    });
  }
}

export async function getById(req: Request, res: Response) {
  try {
    const { id } = apiClientIdSchema.parse(req.params);
    const client = await apiClientService.findApiClientById(id);

    if (!client) {
      return sendNotFound({ res, message: "Cliente no encontrado",
      });
    }

    return sendSuccess({
      res,
      message: "Cliente obtenido exitosamente",
      data: {
        id: client.id,
        clientId: client.clientId,
        name: client.name,
        description: client.description,
        status: client.status,
        scopes: client.scopes,
        rateLimit: client.rateLimit,
        createdAt: client.createdAt,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }
    return sendServerError({ res, message: "Error al obtener cliente",
    });
  }
}

export async function update(req: Request, res: Response) {
  try {
    const { id } = apiClientIdSchema.parse(req.params);
    const data = updateApiClientSchema.parse(req.body);

    const client = await apiClientService.updateApiClient(id, data);

    return sendSuccess({
      res,
      message: "Cliente actualizado exitosamente",
      data: {
        id: client.id,
        clientId: client.clientId,
        name: client.name,
        description: client.description,
        status: client.status,
        scopes: client.scopes,
        rateLimit: client.rateLimit,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }
    return sendServerError({ res, message: "Error al actualizar cliente",
    });
  }
}

export async function regenerateSecret(req: Request, res: Response) {
  try {
    const { id } = apiClientIdSchema.parse(req.params);
    const client = await apiClientService.regenerateClientSecret(id);

    return sendSuccess({
      res,
      message: "Secret regenerado exitosamente",
      data: {
        clientId: client.clientId,
        clientSecret: client.clientSecret,
      },
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }
    return sendServerError({ res, message: "Error al regenerar secret",
    });
  }
}

export async function deactivate(req: Request, res: Response) {
  try {
    const { id } = apiClientIdSchema.parse(req.params);
    await apiClientService.deactivateApiClient(id);

    return sendSuccess({
      res,
      message: "Cliente desactivado exitosamente",
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }
    return sendServerError({ res, message: "Error al desactivar cliente",
    });
  }
}

export async function activate(req: Request, res: Response) {
  try {
    const { id } = apiClientIdSchema.parse(req.params);
    await apiClientService.activateApiClient(id);

    return sendSuccess({
      res,
      message: "Cliente activado exitosamente",
    });
  } catch (error: any) {
    if (error instanceof ZodError) {
      const errors = error.issues.reduce((acc, err) => {
        const path = err.path.join(".");
        acc[path] = err.message;
        return acc;
      }, {} as Record<string, string>);

      return sendValidationError({ res, errors });
    }
    return sendServerError({ res, message: "Error al activar cliente",
    });
  }
}
