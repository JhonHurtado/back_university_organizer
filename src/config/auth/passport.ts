// =====================================================
// passport.config.ts
// =====================================================
import passport from "passport";
import { Strategy as LocalStrategy } from "passport-local";
import { Strategy as BearerStrategy } from "passport-http-bearer";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import { Strategy as ClientPasswordStrategy } from "passport-oauth2-client-password";
import { timingSafeEqual } from "crypto";
import bcrypt from "bcrypt";
import { ENV } from "../config";
import database from "@/lib/prisma/prisma";
import { verifyAccessToken } from "./token.service";

// =====================================================
// UTILS
// =====================================================
function secureCompare(a: string, b: string): boolean {
  const bufA = Buffer.from(a, "utf8");
  const bufB = Buffer.from(b, "utf8");
  if (bufA.length !== bufB.length) {
    timingSafeEqual(bufA, bufA);
    return false;
  }
  return timingSafeEqual(bufA, bufB);
}

// =====================================================
// CLIENT PASSWORD (validar client_id y client_secret)
// =====================================================
passport.use(
  "client-password",
  new ClientPasswordStrategy(async (clientId, clientSecret, done) => {
    try {
      const client = await database.apiClient.findUnique({
        where: { clientId },
      });

      if (!client || client.status !== "ACTIVE") {
        return done(null, false);
      }

      if (!secureCompare(client.clientSecret, clientSecret)) {
        return done(null, false);
      }

      return done(null, client);
    } catch (error) {
      return done(error);
    }
  })
);

// =====================================================
// LOCAL (email + password)
// =====================================================
passport.use(
  "local",
  new LocalStrategy(
    { usernameField: "email", passwordField: "password", session: false },
    async (email, password, done) => {
      try {
        const user = await database.user.findUnique({
          where: { email: email.toLowerCase().trim() },
          include: { subscription: { include: { plan: true } } },
        });

        if (!user || !user.password || !user.isActive || user.deletedAt) {
          await bcrypt.compare(password, "$2b$12$fakehashfortiming");
          return done(null, false, { message: "Credenciales inválidas" });
        }

        const isValid = await bcrypt.compare(password, user.password);
        if (!isValid) {
          return done(null, false, { message: "Credenciales inválidas" });
        }

        return done(null, {
          ...user,
          avatar: user.avatar ?? undefined,
          subscription: user.subscription ?? undefined,
        });
      } catch (error) {
        return done(error);
      }
    }
  )
);

// =====================================================
// BEARER (validar JWT en rutas protegidas)
// =====================================================
passport.use(
  "bearer",
  new BearerStrategy(async (token, done) => {
    try {
      // Usar el servicio centralizado de validación de tokens
      const decoded = await verifyAccessToken(token);

      // Obtener usuario completo con subscription
      const user = await database.user.findUnique({
        where: { id: decoded.sub },
        include: { subscription: { include: { plan: true } } },
      });

      if (!user || !user.isActive || user.deletedAt) {
        return done(null, false);
      }

      return done(null, { ...user, sessionId: decoded.sessionId });
    } catch (error: any) {
      // Errores específicos de token
      console.error("Bearer token validation failed:", error.message);
      return done(null, false);
    }
  })
);

// =====================================================
// GOOGLE OAUTH
// =====================================================
if (ENV.GOOGLE_CLIENT_ID && ENV.GOOGLE_CLIENT_SECRET) {
  passport.use(
    "google",
    new GoogleStrategy(
      {
        clientID: ENV.GOOGLE_CLIENT_ID,
        clientSecret: ENV.GOOGLE_CLIENT_SECRET,
        callbackURL: `${ENV.API_URL}/auth/google/callback`,
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          const email = profile.emails?.[0]?.value?.toLowerCase();
          if (!email) return done(null, false);

          console.log(accessToken, refreshToken);

          const googleId = profile.id;

          let account = await database.account.findUnique({
            where: {
              provider_providerAccountId: {
                provider: "google",
                providerAccountId: googleId,
              },
            },
            include: {
              user: { include: { subscription: { include: { plan: true } } } },
            },
          });

          if (account) {
            if (!account.user.isActive) return done(null, false);
            return done(null, {
              ...account.user,
              avatar: account.user.avatar ?? undefined,
              subscription: account.user.subscription ?? undefined,
            });
          }

          let user = await database.user.findUnique({
            where: { email },
            include: { subscription: { include: { plan: true } } },
          });

          if (user) {
            await database.account.create({
              data: {
                userId: user.id,
                provider: "google",
                providerAccountId: googleId,
                type: "oauth",
              },
            });

            if (!user.emailVerified) {
              user = await database.user.update({
                where: { id: user.id },
                data: { emailVerified: true, emailVerifiedAt: new Date() },
                include: { subscription: { include: { plan: true } } },
              });
            }
          } else {
            user = await database.user.create({
              data: {
                email,
                firstName: profile.name?.givenName || "Usuario",
                lastName: profile.name?.familyName || "",
                avatar: profile.photos?.[0]?.value,
                emailVerified: true,
                emailVerifiedAt: new Date(),
                accounts: {
                  create: {
                    provider: "google",
                    providerAccountId: googleId,
                    type: "oauth",
                  },
                },
                preferences: { create: {} },
              },
              include: { subscription: { include: { plan: true } } },
            });
          }

          return done(null, {
            ...user,
            avatar: user.avatar ?? undefined,
            subscription: user.subscription ?? undefined,
          });
        } catch (error) {
          return done(error);
        }
      }
    )
  );
}

export default passport;
