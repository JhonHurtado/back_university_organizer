// =====================================================
// config/session.ts
// =====================================================
import { ENV } from "./config";
import type { SessionOptions } from "express-session";

// =====================================================
// CONSTANTS
// =====================================================
const ONE_HOUR = 60 * 60 * 1000;
const ONE_DAY = 24 * ONE_HOUR;
const ONE_WEEK = 7 * ONE_DAY;

// =====================================================
// VALIDATION
// =====================================================
if (!ENV.SESSION_SECRET || ENV.SESSION_SECRET === 'default_secret') {
  throw new Error('SESSION_SECRET must be set in environment variables');
}

// =====================================================
// SESSION CONFIG
// =====================================================
export const sessionConfig: SessionOptions = {
  // Secret for signing session ID cookie
  secret: ENV.SESSION_SECRET,
  
  // Don't save session if unmodified
  resave: false,
  
  // Don't create session until something stored
  saveUninitialized: false,
  
  // Session ID cookie name
  name: ENV.NODE_ENV === 'production' ? '__session' : 'sessionId',
  
  // Cookie settings
  cookie: {
    // HTTPS only in production
    secure: ENV.NODE_ENV === 'production',
    
    // Not accessible via JavaScript
    httpOnly: true,
    
    // Duration: 7 days
    maxAge: ONE_WEEK,
    
    // CSRF protection: strict in production, lax in dev
    sameSite: ENV.NODE_ENV === 'production' ? 'strict' : 'lax',
    

    
    // Cookie path
    path: '/',
  },
  
  // Proxy trust (for Heroku, AWS, etc.)
  proxy: ENV.NODE_ENV === 'production',
  
  // Rolling session: reset maxAge on every response
  rolling: true,
  
  // Session store (use Redis/DB in production)
  // store: ENV.NODE_ENV === 'production' ? redisStore : undefined,
};
