// =====================================================
// routes/subscriptions/subscription.routes.ts
// =====================================================
import { Router } from "express";
import * as subscriptionController from "../../controllers/subscriptions/subscription.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// PLAN ROUTES (Admin only - can add middleware later)
// =====================================================
router.post("/plans", requireAuth, subscriptionController.createPlan);
router.get("/plans", subscriptionController.getAllPlans);
router.get("/plans/:id", subscriptionController.getPlanById);
router.put("/plans/:id", requireAuth, subscriptionController.updatePlan);
router.delete("/plans/:id", requireAuth, subscriptionController.deletePlan);

// =====================================================
// SUBSCRIPTION ROUTES
// =====================================================
// Create subscription
router.post("/", requireAuth, subscriptionController.createSubscription);

// Get user's subscriptions
router.get("/", requireAuth, subscriptionController.getSubscriptionsByUser);

// Get active subscription
router.get("/active", requireAuth, subscriptionController.getActiveSubscription);

// Get subscription by ID
router.get("/:id", requireAuth, subscriptionController.getSubscriptionById);

// Update subscription
router.put("/:id", requireAuth, subscriptionController.updateSubscription);

// Change plan
router.put("/:id/plan", requireAuth, subscriptionController.changePlan);

// Cancel subscription
router.post("/:id/cancel", requireAuth, subscriptionController.cancelSubscription);

// Renew subscription
router.post("/:id/renew", requireAuth, subscriptionController.renewSubscription);

// =====================================================
// FEATURE VALIDATION ROUTES
// =====================================================
// Validate feature access
router.get("/features/:featureName/validate", requireAuth, subscriptionController.validateFeatureAccess);

// Validate career limit
router.get("/limits/careers", requireAuth, subscriptionController.validateCareerLimit);

// Validate subject limit
router.get("/limits/subjects/:careerId", requireAuth, subscriptionController.validateSubjectLimit);

export default router;
