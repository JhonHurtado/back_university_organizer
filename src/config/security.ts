import helmet from "helmet";
import rateLimit from "express-rate-limit";
import cors from "cors";



export const helmetConfig = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
});

const ALLOWED_ORIGINS = ["http://localhost:5173","http://192.168.101.5:5173"];

export const corsConfig = cors({
  origin: (origin, callback) => {
    if (!origin || ALLOWED_ORIGINS.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error(`CORS policy: Origin ${origin} not allowed`));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: [
    "Content-Type",
    "Authorization",
    "module",
    "X-Requested-With",
    "Origin",
    "Accept",
    "status_type",
  ],
  credentials: true,
});

// Limiter solo para rutas públicas/globales
export const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Demasiados intentos, por favor intente nuevamente más tarde" },
});

// Limiter solo en rutas de login y reset
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5000,
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // No cuenta los intentos exitosos
  message: { error: "Demasiados intentos de inicio de sesión, por favor intente nuevamente más tarde" },
});

export const authLimiterResetPassword = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Demasiados intentos de restablecimiento de contraseña, por favor intente nuevamente más tarde" },
});
