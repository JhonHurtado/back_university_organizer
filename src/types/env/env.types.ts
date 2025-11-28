export interface EnvConfig {
  PORT: string;
  JWT_SECRET: string;
  JWT_REFRESH_SECRET: string;
  OAUTH_CLIENT_ID: string;
  OAUTH_CLIENT_SECRET: string;
  OAUTH_CLIENT_ID_CUSTOMER: string;
  OAUTH_CLIENT_SECRET_CUSTOMER: string;
  TOKEN_EXPIRATION: string;
  SESSION_SECRET: string;
  DATABASE_URL: string;
  NODE_ENV: string;
  CAPTCHA_SECRET_KEY: string;
  CAPTCHA_VERIFY_URL: string;

  EMAIL_FROM_NAME: string | undefined;
  EMAIL_SERVICE: string | undefined;
  EMAIL_HOST: string | undefined;
  EMAIL_PORT: string | undefined;
  EMAIL_SECURE: string | undefined;
  EMAIL_USER: string | undefined;
  EMAIL_PASSWORD: string | undefined;
  OTP_EXPIRATION_MINUTES: number | string | undefined;

  AWS_REGION: string;
  AWS_ACCESS_KEY_ID: string;
  AWS_SECRET_ACCESS_KEY: string;
  S3_BUCKET: string;

  ENCRYPTION_ALGORITHM: string;
  ENCRYPTION_KEY: string;
  ENCRYPTION_IV: string;

  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  JWT_ISSUER: string;

  FRONTEND_URL: string;
  API_URL: string;
}
