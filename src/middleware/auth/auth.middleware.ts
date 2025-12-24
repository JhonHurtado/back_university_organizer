// =====================================================
// auth.middleware.ts
// =====================================================
import type { Request, Response, NextFunction } from "express";
import passport from "../../config/auth/passport";

// =====================================================
// REQUIRE AUTH (Bearer token)
// =====================================================
export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  passport.authenticate("bearer", { session: false }, (err: any, user: any) => {
    if (err) {
      return res.status(500).json({ error: "server_error" });
    }

    console.log(user);

    if (!user) {
      return res.status(401).json({ error: "unauthorized" });
    }

    req.user = user;
    return next();
  })(req, res, next);
};

// =====================================================
// OPTIONAL AUTH (no falla si no hay token)
// =====================================================
export const optionalAuth = (req: Request, res: Response, next: NextFunction) => {
  passport.authenticate("bearer", { session: false }, (_err: any, user: any) => {
    if (user) {
      req.user = user;
    }
    next();
  })(req, res, next);
};

// =====================================================
// REQUIRE VERIFIED EMAIL
// =====================================================
export const requireVerifiedEmail = (req: Request, res: Response, next: NextFunction) => {
  const user = req.user as any;

  if (!user?.emailVerified) {
    return res.status(403).json({ error: "email_not_verified" });
  }

  return next();
};

// =====================================================
// REQUIRE ACTIVE SUBSCRIPTION
// =====================================================
export const requireSubscription = (req: Request, res: Response, next: NextFunction) => {
  const user = req.user as any;

  if (!user?.subscription) {
    return res.status(403).json({ error: "subscription_required" });
  }

  const validStatuses = ["ACTIVE", "TRIAL"];
  if (!validStatuses.includes(user.subscription.status)) {
    return res.status(403).json({ error: "subscription_inactive" });
  }

  if (new Date() > new Date(user.subscription.endDate)) {
    return res.status(403).json({ error: "subscription_expired" });
  }

  return next();
};

// =====================================================
// REQUIRE SPECIFIC PLAN
// =====================================================
export const requirePlan = (...plans: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user as any;

    if (!user?.subscription) {
      return res.status(403).json({ error: "subscription_required" });
    }

    const userPlan = user.subscription.plan.slug || user.subscription.plan.name;

    if (!plans.includes(userPlan)) {
      return res.status(403).json({
        error: "plan_not_allowed",
        required: plans,
        current: userPlan,
      });
    }

    return next();
  };
};

// =====================================================
// REQUIRE FEATURE
// =====================================================
export const requireFeature = (feature: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user as any;
    const plan = user?.subscription?.plan;

    if (!plan) {
      return res.status(403).json({ error: "subscription_required" });
    }

    const hasFeature = plan[feature] === true;

    if (!hasFeature) {
      return res.status(403).json({ error: "feature_not_available", feature });
    }

    return next();
  };
};

// =====================================================
// COMBINADOS
// =====================================================
export const requireFullAuth = [requireAuth, requireVerifiedEmail];
export const requirePremium = [requireAuth, requireVerifiedEmail, requireSubscription];