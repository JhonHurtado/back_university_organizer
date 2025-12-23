export interface EnvConfig {
  // =====================================================
  // SERVER CONFIGURATION
  // =====================================================
  PORT: string;
  NODE_ENV: string;
  API_URL: string;
  FRONTEND_URL: string;

  // =====================================================
  // JWT & AUTHENTICATION
  // =====================================================
  JWT_SECRET: string;
  JWT_REFRESH_SECRET: string;
  JWT_ISSUER: string;
  TOKEN_EXPIRATION: string;
  SESSION_SECRET: string;

  // =====================================================
  // GOOGLE OAUTH
  // =====================================================
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;

  // =====================================================
  // EMAIL CONFIGURATION (SMTP)
  // =====================================================
  SMTP_HOST: string;
  SMTP_PORT: string;
  SMTP_SECURE: string;
  SMTP_USER: string;
  SMTP_PASS: string;
  EMAIL_FROM: string;
  EMAIL_FROM_NAME: string;
}
