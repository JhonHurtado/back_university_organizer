// =====================================================
// types/jwt/JWT.types.ts
// =====================================================

export interface JWTPayload {
  /** User ID */
  sub: string;
  /** Session ID */
  sessionId: string;
  /** Email */
  email: string;
  /** Scopes */
  scope?: string[];
  /** Issued at (auto) */
  iat?: number;
  /** Expiration (auto) */
  exp?: number;
  /** Issuer (auto) */
  iss?: string;
  /** Audience (auto) */
  aud?: string;
}

export interface RefreshTokenPayload {
  sub: string;
  sessionId: string;
  type: "refresh";
  iat?: number;
  exp?: number;
  iss?: string;
  aud?: string;
}

export interface GoogleTokenPayload {
  sub: string;
  email: string;
  email_verified: boolean;
  given_name?: string;
  family_name?: string;
  name?: string;
  picture?: string;
  locale?: string;
}

export interface AuthUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  avatar?: string;
  emailVerified: boolean;
  sessionId?: string;
  subscription?: {
    status: string;
    plan: {
      name: string;
      slug: string;
      canExportPDF: boolean;
      canExportExcel: boolean;
      hasAnalytics: boolean;
    };
    endDate: Date;
  };
}

// Express augmentation
declare global {
  namespace Express {
    interface User extends AuthUser {}
  }
}

export {};