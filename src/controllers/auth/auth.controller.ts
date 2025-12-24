import type { Request, Response, NextFunction } from "express";
import passport from "../../config/auth/passport";
import { AuthService } from "@/services/auth/auth.service";
import { ENV } from "@/config/config";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
  sendBadRequest,
  sendConflict,
  sendServerError,
  ErrorCode,
} from "@/utils/response/apiResponse";

const authService = new AuthService();

export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  passport.authenticate(
    "client-password",
    { session: false },
    async (err: any, client: any) => {
      if (err || !client) {
        return sendUnauthorized({
          res,
          message: "Cliente no autorizado",
          error: "INVALID_CLIENT",
        });
      }

      const { email, password, firstName, lastName } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return sendBadRequest({
          res,
          message: "Todos los campos son requeridos",
        });
      }

      try {
        const user = await authService.register({
          email,
          password,
          firstName,
          lastName,
        });
        const response = await authService.buildAuthResponse(
          user,
          client.clientId
        );
        return sendCreated({
          res,
          data: response,
          message: "Usuario registrado exitosamente",
        });
      } catch (error: any) {
        if (error.message === "EMAIL_EXISTS") {
          return sendConflict({
            res,
            message: "El email ya está registrado",
          });
        }
        return sendServerError({
          res,
          message: "Error al registrar el usuario",
        });
      }
    }
  )(req, res, next);
};

export const login = (req: Request, res: Response, next: NextFunction) => {
  passport.authenticate(
    "client-password",
    { session: false },
    (err: any, client: any) => {
      if (err || !client) {
        return sendUnauthorized({
          res,
          message: "Cliente no autorizado",
          error: "INVALID_CLIENT",
        });
      }

      return passport.authenticate(
        "local",
        { session: false },
        async (err: any, user: any, info: any) => {
          if (err) {
            return sendServerError({
              res,
              message: "Error al iniciar sesión",
            });
          }
          if (!user) {
            return sendUnauthorized({
              res,
              message: info?.message || "Credenciales inválidas",
              error: ErrorCode.INVALID_CREDENTIALS,
            });
          }

          try {
            const response = await authService.buildAuthResponse(
              user,
              client.clientId
            );
            return sendSuccess({
              res,
              data: response,
              message: "Sesión iniciada exitosamente",
            });
          } catch (error) {
            return sendServerError({
              res,
              message: "Error al iniciar sesión",
            });
          }
        }
      )(req, res, next);
    }
  )(req, res, next);
};

export const refresh = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  passport.authenticate(
    "client-password",
    { session: false },
    async (err: any, client: any) => {
      if (err || !client) {
        return sendUnauthorized({
          res,
          message: "Cliente no autorizado",
          error: "INVALID_CLIENT",
        });
      }

      const { refresh_token } = req.body;
      if (!refresh_token) {
        return sendBadRequest({
          res,
          message: "El refresh token es requerido",
        });
      }

      try {
        const { accessToken, refreshToken, user, expiresIn } = await authService.refreshToken(
          refresh_token,
          client.clientId
        );

        return sendSuccess({
          res,
          data: {
            access_token: accessToken,
            refresh_token: refreshToken, // Nuevo refresh token (rotación)
            token_type: "Bearer",
            expires_in: expiresIn,
            user: {
              id: user.id,
              email: user.email,
              fullName: `${user.firstName} ${user.lastName}`,
            },
          },
          message: "Token renovado exitosamente",
        });
      } catch (error: any) {
        return sendUnauthorized({
          res,
          message: "Refresh token inválido o expirado",
          error: "INVALID_REFRESH_TOKEN",
        });
      }
    }
  )(req, res, next);
};

export const googleAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  passport.authenticate(
    "client-password",
    { session: false },
    async (err: any, client: any) => {
      if (err || !client) {
        return sendUnauthorized({
          res,
          message: "Cliente no autorizado",
          error: "INVALID_CLIENT",
        });
      }

      const { id_token, access_token } = req.body;
      if (!id_token && !access_token) {
        return sendBadRequest({
          res,
          message: "Se requiere un token de Google",
        });
      }

      try {
        const googleData = await authService.verifyGoogleToken(
          id_token,
          access_token
        );
        const user = await authService.findOrCreateGoogleUser(googleData);
        const response = await authService.buildAuthResponse(
          user,
          client.clientId
        );
        return sendSuccess({
          res,
          data: response,
          message: "Autenticación con Google exitosa",
        });
      } catch (error: any) {
        if (error.message === "INVALID_TOKEN") {
          return sendUnauthorized({
            res,
            message: "Token de Google inválido",
            error: ErrorCode.INVALID_TOKEN,
          });
        }
        if (error.message === "ACCOUNT_DISABLED") {
          return sendUnauthorized({
            res,
            message: "Cuenta deshabilitada",
            error: ErrorCode.ACCOUNT_DISABLED,
          });
        }
        return sendUnauthorized({
          res,
          message: "Falló la autenticación con Google",
        });
      }
    }
  )(req, res, next);
};

export const googleCallback = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  passport.authenticate(
    "google",
    { session: false },
    async (err: any, user: any) => {
      if (err || !user) return res.redirect(`${ENV.FRONTEND_URL}/auth/error`);

      try {
        const client = await authService.getDefaultClient();
        if (!client) return res.redirect(`${ENV.FRONTEND_URL}/auth/error`);

        const response = await authService.buildAuthResponse(
          user,
          client.clientId
        );
        const params = new URLSearchParams({
          access_token: response.access_token,
          refresh_token: response.refresh_token,
        });

        return res.redirect(`${ENV.FRONTEND_URL}/auth/callback?${params}`);
      } catch (error) {
        return res.redirect(`${ENV.FRONTEND_URL}/auth/error`);
      }
    }
  )(req, res, next);
};

export const logout = async (req: Request, res: Response) => {
  try {
    const user = req.user as any;
    if (user?.sessionId) await authService.invalidateSession(user.sessionId);
    return sendSuccess({
      res,
      data: null,
      message: "Sesión cerrada correctamente",
    });
  } catch (error) {
    return sendServerError({
      res,
      message: "Error al cerrar sesión",
    });
  }
};

export const logoutAll = async (req: Request, res: Response) => {
  try {
    const user = req.user as any;
    if (user?.id) await authService.invalidateAllSessions(user.id);
    return sendSuccess({
      res,
      data: null,
      message: "Todas las sesiones cerradas correctamente",
    });
  } catch (error) {
    return sendServerError({
      res,
      message: "Error al cerrar sesiones",
    });
  }
};

export const me = async (req: Request, res: Response) => {
  const user = req.user as any;
  return sendSuccess({
    res,
    data: {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatar: user.avatar,
      emailVerified: user.emailVerified,
      subscription: user.subscription
        ? {
            status: user.subscription.status,
            plan: user.subscription.plan.name,
          }
        : null,
    },
    message: "Información del usuario obtenida exitosamente",
  });
};
