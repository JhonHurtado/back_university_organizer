import type {
  Session,
  User,
  Subscription,
  Plan,
} from "generated/prisma/client";

export interface CreateSessionData {
  userId: string;
  ipAddress?: string;
  userAgent?: string;
  deviceType?: string;
}

export interface SessionWithUser extends Session {
  user: User & {
    subscription:
      | (Subscription & {
          plan: Plan;
        })
      | null;
  };
}

export interface ActiveSessionInfo {
  id: string;
  ipAddress: string | null;
  userAgent: string | null;
  deviceType: string | null;
  createdAt: Date;
  expiresAt: Date;
}
