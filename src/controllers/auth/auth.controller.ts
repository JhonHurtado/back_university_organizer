import type { Request, Response, NextFunction } from "express";
import passport from "../../config/auth/passport";
import { AuthService } from "@/services/auth/auth.service";

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
      if (err || !client)
        return res.status(401).json({ error: "invalid_client" });

      const { email, password, firstName, lastName } = req.body;

      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({ error: "missing_fields" });
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
          client.clientId,
          req.ip,
          req.headers["user-agent"]
        );
        return res.status(201).json(response);
      } catch (error: any) {
        if (error.message === "EMAIL_EXISTS") {
          return res.status(409).json({ error: "email_exists" });
        }
        return res.status(500).json({ error: "server_error" });
      }
    }
  )(req, res, next);
};

export const login = (req: Request, res: Response, next: NextFunction) => {
  passport.authenticate(
    "client-password",
    { session: false },
    (err: any, client: any) => {
      if (err || !client)
        return res.status(401).json({ error: "invalid_client" });

      return passport.authenticate(
        "local",
        { session: false },
        async (err: any, user: any, info: any) => {
          if (err) return res.status(500).json({ error: "server_error" });
          if (!user)
            return res
              .status(401)
              .json({ error: "invalid_credentials", message: info?.message });

          try {
            const response = await authService.buildAuthResponse(
              user,
              client.clientId,
              req.ip,
              req.headers["user-agent"]
            );
            return res.json(response);
          } catch (error) {
            return res.status(500).json({ error: "server_error" });
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
      if (err || !client)
        return res.status(401).json({ error: "invalid_client" });

      const { refresh_token } = req.body;
      if (!refresh_token)
        return res.status(400).json({ error: "refresh_token_required" });

      try {
        const { accessToken, user, expiresIn } = await authService.refreshToken(
          refresh_token,
          client.clientId
        );

        return res.json({
          access_token: accessToken,
          refresh_token,
          token_type: "Bearer",
          expires_in: expiresIn,
          user: {
            id: user.id,
            email: user.email,
            fullName: `${user.firstName} ${user.lastName}`,
          },
        });
      } catch (error: any) {
        return res.status(401).json({ error: "invalid_refresh_token" });
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
      if (err || !client)
        return res.status(401).json({ error: "invalid_client" });

      const { id_token, access_token } = req.body;
      if (!id_token && !access_token)
        return res.status(400).json({ error: "token_required" });

      try {
        const googleData = await authService.verifyGoogleToken(
          id_token,
          access_token
        );
        const user = await authService.findOrCreateGoogleUser(googleData);
        const response = await authService.buildAuthResponse(
          user,
          client.clientId,
          req.ip,
          req.headers["user-agent"]
        );
        return res.json(response);
      } catch (error: any) {
        if (error.message === "INVALID_TOKEN") {
          return res.status(401).json({ error: "invalid_token" });
        }
        if (error.message === "ACCOUNT_DISABLED") {
          return res.status(401).json({ error: "account_disabled" });
        }
        return res.status(401).json({ error: "authentication_failed" });
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
      if (err || !user)
        return res.redirect(`${process.env.FRONTEND_URL}/auth/error`);

      try {
        const client = await authService.getDefaultClient();
        if (!client)
          return res.redirect(`${process.env.FRONTEND_URL}/auth/error`);

        const response = await authService.buildAuthResponse(
          user,
          client.clientId,
          req.ip,
          req.headers["user-agent"]
        );
        const params = new URLSearchParams({
          access_token: response.access_token,
          refresh_token: response.refresh_token,
        });

        return res.redirect(
          `${process.env.FRONTEND_URL}/auth/callback?${params}`
        );
      } catch (error) {
        return res.redirect(`${process.env.FRONTEND_URL}/auth/error`);
      }
    }
  )(req, res, next);
};

export const logout = async (req: Request, res: Response) => {
  try {
    const user = req.user as any;
    if (user?.sessionId) await authService.invalidateSession(user.sessionId);
    return res.json({ message: "Sesión cerrada correctamente" });
  } catch (error) {
    return res.status(500).json({ error: "server_error" });
  }
};

export const logoutAll = async (req: Request, res: Response) => {
  try {
    const user = req.user as any;
    if (user?.id) await authService.invalidateAllSessions(user.id);
    return res.json({ message: "Todas las sesiones cerradas" });
  } catch (error) {
    return res.status(500).json({ error: "server_error" });
  }
};

export const me = async (req: Request, res: Response) => {
  const user = req.user as any;
  return res.json({
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
  });
};
