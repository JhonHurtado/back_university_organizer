import { ENV } from "./config";
import type { SessionOptions } from "express-session";

export const sessionConfig: SessionOptions = {
  secret: ENV.SESSION_SECRET || 'default_secret',
  resave: false,
  saveUninitialized: false,
  name: 'sessionId',
  cookie: {
    secure: ENV.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
    sameSite: 'strict'
  }
};