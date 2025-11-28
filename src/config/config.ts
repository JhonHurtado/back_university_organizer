import type { EnvConfig } from "@/types/env/env.types";
import dotenv from "dotenv";
dotenv.config();

export const ENV: EnvConfig = {
  PORT: process.env.PORT || "",
  JWT_SECRET: process.env.JWT_SECRET || "",
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || "",
  OAUTH_CLIENT_ID: process.env.OAUTH_CLIENT_ID || "",
  OAUTH_CLIENT_SECRET: process.env.OAUTH_CLIENT_SECRET || "",
  OAUTH_CLIENT_ID_CUSTOMER: process.env.OAUTH_CLIENT_ID_CUSTOMER || "",
  OAUTH_CLIENT_SECRET_CUSTOMER: process.env.OAUTH_CLIENT_SECRET_CUSTOMER || "",

  TOKEN_EXPIRATION: process.env.TOKEN_EXPIRATION || "",
  DATABASE_URL: process.env.DATABASE_URL || "",
  NODE_ENV: process.env.NODE_ENV || "development",
  CAPTCHA_SECRET_KEY: process.env.CAPTCHA_SECRET_KEY || "",
  CAPTCHA_VERIFY_URL:
    process.env.CAPTCHA_VERIFY_URL ||
    "https://www.google.com/recaptcha/api/siteverify",

  EMAIL_FROM_NAME: process.env.EMAIL_FROM_NAME,
  EMAIL_SERVICE: process.env.EMAIL_SERVICE,
  EMAIL_HOST: process.env.EMAIL_HOST,
  EMAIL_PORT: process.env.EMAIL_PORT,
  EMAIL_SECURE: process.env.EMAIL_SECURE,
  EMAIL_USER: process.env.EMAIL_USER,
  EMAIL_PASSWORD: process.env.EMAIL_PASSWORD,
  OTP_EXPIRATION_MINUTES: process.env.OTP_EXPIRATION_MINUTES,

  // AWS S3 settings
  AWS_REGION: process.env.AWS_REGION || "",
  AWS_ACCESS_KEY_ID: process.env.AWS_ACCESS_KEY_ID || "",
  AWS_SECRET_ACCESS_KEY: process.env.AWS_SECRET_ACCESS_KEY || "",
  S3_BUCKET: process.env.S3_BUCKET || "",

  // Encryption settings
  ENCRYPTION_ALGORITHM: process.env.ENCRYPTION_ALGORITHM || "aes-256-cbc",
  ENCRYPTION_KEY: process.env.ENCRYPTION_KEY || "",
  ENCRYPTION_IV: process.env.ENCRYPTION_IV || "",

  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || "",
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || "",
  JWT_ISSUER: process.env.JWT_ISSUER || "your-app-name",







  //=======================================================================
  FRONTEND_URL: process.env.FRONTEND_URL || "",
  API_URL: process.env.API_URL || "",
  SESSION_SECRET: process.env.SESSION_SECRET || "default_secret",

};
