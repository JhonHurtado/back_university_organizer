// =====================================================
// services/subscriptions/subscription.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreatePlanInput,
  UpdatePlanInput,
  CreateSubscriptionInput,
  UpdateSubscriptionInput,
  ChangePlanInput,
  CancelSubscriptionInput,
  SubscriptionQueryInput,
} from "@/types/schemas/subscriptions/subscription.schemas";
import type { Plan, Subscription } from "@prisma/client";

// =====================================================
// SUBSCRIPTION SERVICE
// =====================================================
class SubscriptionService {
  // =====================================================
  // PLAN MANAGEMENT
  // =====================================================
  async createPlan(data: CreatePlanInput): Promise<Plan> {
    const plan = await database.plan.create({
      data: {
        ...data,
        features: data.features as any,
      },
    });

    return plan;
  }

  async getAllPlans(activeOnly: boolean = true): Promise<Plan[]> {
    const plans = await database.plan.findMany({
      where: activeOnly ? { isActive: true, state: "A" } : { state: "A" },
      orderBy: { price: "asc" },
    });

    return plans;
  }

  async getPlanById(id: string): Promise<Plan | null> {
    const plan = await database.plan.findFirst({
      where: { id, state: "A" },
    });

    return plan;
  }

  async updatePlan(id: string, data: UpdatePlanInput): Promise<Plan> {
    const plan = await database.plan.findFirst({
      where: { id, state: "A" },
    });

    if (!plan) {
      throw new Error("PLAN_NOT_FOUND");
    }

    const updateData: any = { ...data };
    if (data.features !== undefined) {
      updateData.features = data.features as any;
    }

    const updated = await database.plan.update({
      where: { id },
      data: updateData,
    });

    return updated;
  }

  async deletePlan(id: string): Promise<void> {
    const plan = await database.plan.findFirst({
      where: { id, state: "A" },
    });

    if (!plan) {
      throw new Error("PLAN_NOT_FOUND");
    }

    // Check if plan has active subscriptions
    const activeSubscriptions = await database.subscription.count({
      where: {
        planId: id,
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
    });

    if (activeSubscriptions > 0) {
      throw new Error("PLAN_HAS_ACTIVE_SUBSCRIPTIONS");
    }

    await database.plan.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // SUBSCRIPTION MANAGEMENT
  // =====================================================
  async createSubscription(data: CreateSubscriptionInput): Promise<Subscription> {
    // Verify user exists
    const user = await database.user.findUnique({
      where: { id: data.userId },
    });

    if (!user) {
      throw new Error("USER_NOT_FOUND");
    }

    // Verify plan exists and is active
    const plan = await database.plan.findFirst({
      where: { id: data.planId, isActive: true, state: "A" },
    });

    if (!plan) {
      throw new Error("PLAN_NOT_FOUND");
    }

    // Check if user already has an active subscription
    const existingSubscription = await database.subscription.findFirst({
      where: {
        userId: data.userId,
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
    });

    if (existingSubscription) {
      throw new Error("USER_HAS_ACTIVE_SUBSCRIPTION");
    }

    // Calculate dates
    const startDate = data.startDate || new Date();
    const trialEndsAt = plan.trialDays > 0
      ? new Date(startDate.getTime() + plan.trialDays * 24 * 60 * 60 * 1000)
      : null;

    let endDate = data.endDate;
    if (!endDate) {
      const duration = this.getBillingPeriodDuration(plan.billingPeriod);
      endDate = new Date(startDate.getTime() + duration);
    }

    const subscription = await database.subscription.create({
      data: {
        userId: data.userId,
        planId: data.planId,
        status: plan.trialDays > 0 ? "TRIAL" : data.status,
        startDate,
        endDate,
        trialEndsAt,
        autoRenew: data.autoRenew,
      },
      include: {
        plan: true,
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return subscription as any;
  }

  async getSubscriptionsByUser(
    userId: string,
    filters?: SubscriptionQueryInput
  ): Promise<{
    subscriptions: Subscription[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      userId,
      state: "A",
      ...(filters?.status && { status: filters.status }),
    };

    if (filters?.planType) {
      where.plan = {
        type: filters.planType,
      };
    }

    const [subscriptions, total] = await Promise.all([
      database.subscription.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          plan: true,
        },
      }),
      database.subscription.count({ where }),
    ]);

    return {
      subscriptions: subscriptions as any,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getActiveSubscription(userId: string): Promise<Subscription | null> {
    const subscription = await database.subscription.findFirst({
      where: {
        userId,
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
      include: {
        plan: true,
      },
      orderBy: { createdAt: "desc" },
    });

    return subscription as any;
  }

  async getSubscriptionById(id: string): Promise<Subscription | null> {
    const subscription = await database.subscription.findFirst({
      where: { id, state: "A" },
      include: {
        plan: true,
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return subscription as any;
  }

  async updateSubscription(
    id: string,
    data: UpdateSubscriptionInput
  ): Promise<Subscription> {
    const subscription = await database.subscription.findFirst({
      where: { id, state: "A" },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    const updated = await database.subscription.update({
      where: { id },
      data,
      include: {
        plan: true,
      },
    });

    return updated as any;
  }

  async changePlan(
    subscriptionId: string,
    userId: string,
    data: ChangePlanInput
  ): Promise<Subscription> {
    const subscription = await database.subscription.findFirst({
      where: {
        id: subscriptionId,
        userId,
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
      include: { plan: true },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    const newPlan = await database.plan.findFirst({
      where: { id: data.newPlanId, isActive: true, state: "A" },
    });

    if (!newPlan) {
      throw new Error("PLAN_NOT_FOUND");
    }

    // Always do immediate plan change (since nextPlanId doesn't exist in schema)
    const updated = await database.subscription.update({
      where: { id: subscriptionId },
      data: {
        planId: data.newPlanId,
        // Recalculate end date based on new plan
        endDate: new Date(
          Date.now() + this.getBillingPeriodDuration(newPlan.billingPeriod)
        ),
      },
      include: { plan: true },
    });

    return updated as any;
  }

  async cancelSubscription(
    subscriptionId: string,
    userId: string,
    data: CancelSubscriptionInput
  ): Promise<Subscription> {
    const subscription = await database.subscription.findFirst({
      where: {
        id: subscriptionId,
        userId,
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    const updateData: any = {
      cancelledAt: new Date(),
      cancellationReason: data.reason,
      autoRenew: false,
      status: "CANCELLED",
    };

    if (data.immediate) {
      updateData.endDate = new Date();
    }

    const updated = await database.subscription.update({
      where: { id: subscriptionId },
      data: updateData,
      include: { plan: true },
    });

    return updated as any;
  }

  async renewSubscription(subscriptionId: string): Promise<Subscription> {
    const subscription = await database.subscription.findFirst({
      where: { id: subscriptionId, state: "A" },
      include: { plan: true },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    const plan = await database.plan.findFirst({
      where: { id: subscription.planId, state: "A" },
    });

    if (!plan) {
      throw new Error("PLAN_NOT_FOUND");
    }

    const newEndDate = new Date(
      Date.now() + this.getBillingPeriodDuration(plan.billingPeriod)
    );

    const updated = await database.subscription.update({
      where: { id: subscriptionId },
      data: {
        status: "ACTIVE",
        startDate: new Date(),
        endDate: newEndDate,
        trialEndsAt: null,
      },
      include: { plan: true },
    });

    return updated as any;
  }

  // =====================================================
  // FEATURE VALIDATION
  // =====================================================
  async validateFeatureAccess(
    userId: string,
    featureName: string
  ): Promise<boolean> {
    const subscription = await this.getActiveSubscription(userId);

    if (!subscription) {
      return false;
    }

    // Fetch plan if not included
    const plan = await database.plan.findFirst({
      where: { id: subscription.planId, state: "A" },
    });

    if (!plan) {
      return false;
    }

    const features = plan.features as Record<string, boolean>;

    return features[featureName] === true;
  }

  async validateCareerLimit(userId: string): Promise<{
    allowed: boolean;
    current: number;
    max: number;
  }> {
    const subscription = await this.getActiveSubscription(userId);

    if (!subscription) {
      return { allowed: false, current: 0, max: 0 };
    }

    const plan = await database.plan.findFirst({
      where: { id: subscription.planId, state: "A" },
    });

    if (!plan) {
      return { allowed: false, current: 0, max: 0 };
    }

    const currentCareers = await database.career.count({
      where: { userId, state: "A" },
    });

    return {
      allowed: currentCareers < plan.maxCareers,
      current: currentCareers,
      max: plan.maxCareers,
    };
  }

  async validateSubjectLimit(
    userId: string,
    careerId: string
  ): Promise<{
    allowed: boolean;
    current: number;
    max: number;
  }> {
    const subscription = await this.getActiveSubscription(userId);

    if (!subscription) {
      return { allowed: false, current: 0, max: 0 };
    }

    const plan = await database.plan.findFirst({
      where: { id: subscription.planId, state: "A" },
    });

    if (!plan) {
      return { allowed: false, current: 0, max: 0 };
    }

    // Count subjects in this career
    const currentSubjects = await database.subject.count({
      where: {
        semester: {
          careerId,
          career: {
            userId,
          },
        },
        state: "A",
      },
    });

    return {
      allowed: currentSubjects < plan.maxSubjectsPerCareer,
      current: currentSubjects,
      max: plan.maxSubjectsPerCareer,
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================
  private getBillingPeriodDuration(period: string): number {
    switch (period) {
      case "MONTHLY":
        return 30 * 24 * 60 * 60 * 1000; // 30 days
      case "QUARTERLY":
        return 90 * 24 * 60 * 60 * 1000; // 90 days
      case "SEMI_ANNUAL":
        return 180 * 24 * 60 * 60 * 1000; // 180 days
      case "ANNUAL":
        return 365 * 24 * 60 * 60 * 1000; // 365 days
      case "LIFETIME":
        return 100 * 365 * 24 * 60 * 60 * 1000; // 100 years
      default:
        return 30 * 24 * 60 * 60 * 1000;
    }
  }

  // =====================================================
  // SCHEDULED TASKS
  // =====================================================
  async checkExpiredSubscriptions(): Promise<{ count: number }> {
    const result = await database.subscription.updateMany({
      where: {
        endDate: { lt: new Date() },
        status: { in: ["ACTIVE", "TRIAL"] },
        state: "A",
      },
      data: {
        status: "EXPIRED",
      },
    });

    return { count: result.count };
  }

  async processAutoRenewals(): Promise<{ count: number }> {
    const subscriptions = await database.subscription.findMany({
      where: {
        endDate: { lte: new Date() },
        autoRenew: true,
        status: "ACTIVE",
        state: "A",
      },
      include: { plan: true },
    });

    let renewedCount = 0;

    for (const subscription of subscriptions) {
      try {
        await this.renewSubscription(subscription.id);
        renewedCount++;
      } catch (error) {
        console.error(`Failed to renew subscription ${subscription.id}:`, error);
      }
    }

    return { count: renewedCount };
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const subscriptionService = new SubscriptionService();
