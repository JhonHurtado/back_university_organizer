import type { EnvConfig } from "@/types/env/env.types";
import dotenv from "dotenv";
dotenv.config();

export const ENV: EnvConfig = {
  // =====================================================
  // SERVER CONFIGURATION
  // =====================================================
  PORT: process.env.PORT || "3000",
  NODE_ENV: process.env.NODE_ENV || "development",
  API_URL: process.env.API_URL || "http://localhost:3000",
  FRONTEND_URL: process.env.FRONTEND_URL || "http://localhost:3001",

  // =====================================================
  // JWT & AUTHENTICATION
  // =====================================================
  JWT_SECRET: process.env.JWT_SECRET || "",
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || "",
  JWT_ISSUER: process.env.JWT_ISSUER || "university-organizer",
  TOKEN_EXPIRATION: process.env.TOKEN_EXPIRATION || "900", // 15 minutos en segundos
  SESSION_SECRET: process.env.SESSION_SECRET || "",

  // =====================================================
  // GOOGLE OAUTH
  // =====================================================
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || "",
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || "",

  // =====================================================
  // EMAIL CONFIGURATION (SMTP)
  // =====================================================
  SMTP_HOST: process.env.SMTP_HOST || "smtp.gmail.com",
  SMTP_PORT: process.env.SMTP_PORT || "587",
  SMTP_SECURE: process.env.SMTP_SECURE || "false",
  SMTP_USER: process.env.SMTP_USER || "",
  SMTP_PASS: process.env.SMTP_PASS || "",
  EMAIL_FROM: process.env.EMAIL_FROM || process.env.SMTP_USER || "noreply@university-organizer.com",
  EMAIL_FROM_NAME: process.env.EMAIL_FROM_NAME || "University Organizer",
};
