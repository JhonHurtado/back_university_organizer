// =====================================================
// services/payments/payment.service.ts
// =====================================================
import database from "@/lib/prisma/prisma";
import type {
  CreatePaymentInput,
  UpdatePaymentInput,
  RefundPaymentInput,
  CreateInvoiceInput,
  UpdateInvoiceInput,
  PaymentQueryInput,
  InvoiceQueryInput,
} from "@/types/schemas/payments/payment.schemas";
import type { Payment, Invoice } from "generated/prisma/client";

// =====================================================
// PAYMENT SERVICE
// =====================================================
class PaymentService {
  // =====================================================
  // PAYMENT MANAGEMENT
  // =====================================================
  async createPayment(data: CreatePaymentInput): Promise<Payment> {
    // Verify subscription exists
    const subscription = await database.subscription.findFirst({
      where: { id: data.subscriptionId, state: "A" },
      include: { plan: true },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    const payment = await database.payment.create({
      data: {
        subscriptionId: data.subscriptionId,
        amount: data.amount,
        currency: data.currency,
        method: data.paymentMethod,
        status: data.status,
        transactionId: data.transactionId,
        metadata: data.metadata as any,
      },
      include: {
        subscription: {
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
        },
      },
    });

    return payment as any;
  }

  async getPaymentById(id: string): Promise<Payment | null> {
    const payment = await database.payment.findFirst({
      where: { id, state: "A" },
      include: {
        subscription: {
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
        },
      },
    });

    return payment as any;
  }

  async getPaymentsBySubscription(
    subscriptionId: string,
    filters?: PaymentQueryInput
  ): Promise<{
    payments: Payment[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      subscriptionId,
      state: "A",
      ...(filters?.status && { status: filters.status }),
      ...(filters?.paymentMethod && { paymentMethod: filters.paymentMethod }),
    };

    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const [payments, total] = await Promise.all([
      database.payment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          subscription: {
            include: { plan: true },
          },
        },
      }),
      database.payment.count({ where }),
    ]);

    return {
      payments: payments as any,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getPaymentsByUser(
    userId: string,
    filters?: PaymentQueryInput
  ): Promise<{
    payments: Payment[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      subscription: {
        userId,
      },
      state: "A",
      ...(filters?.status && { status: filters.status }),
      ...(filters?.paymentMethod && { paymentMethod: filters.paymentMethod }),
    };

    if (filters?.subscriptionId) {
      where.subscriptionId = filters.subscriptionId;
    }

    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const [payments, total] = await Promise.all([
      database.payment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          subscription: {
            include: { plan: true },
          },
        },
      }),
      database.payment.count({ where }),
    ]);

    return {
      payments: payments as any,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async updatePayment(id: string, data: UpdatePaymentInput): Promise<Payment> {
    const payment = await database.payment.findFirst({
      where: { id, state: "A" },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    const updateData: any = { ...data };
    if (data.metadata !== undefined) {
      updateData.metadata = data.metadata as any;
    }

    const updated = await database.payment.update({
      where: { id },
      data: updateData,
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    return updated as any;
  }

  async processPayment(paymentId: string): Promise<Payment> {
    const payment = await database.payment.findFirst({
      where: { id: paymentId, state: "A" },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    if (payment.status !== "PENDING") {
      throw new Error("PAYMENT_ALREADY_PROCESSED");
    }

    // TODO: Integrate with payment gateway (Stripe, PayPal, etc.)
    // For now, we'll mark it as processing
    const updated = await database.payment.update({
      where: { id: paymentId },
      data: {
        status: "PROCESSING",
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    return updated as any;
  }

  async completePayment(
    paymentId: string,
    transactionId: string
  ): Promise<Payment> {
    const payment = await database.payment.findFirst({
      where: { id: paymentId, state: "A" },
      include: { subscription: true },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    const updated = await database.payment.update({
      where: { id: paymentId },
      data: {
        status: "COMPLETED",
        transactionId,
        paidAt: new Date(),
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    // Update subscription status if it was in PAST_DUE
    if (payment.subscription.status === "PAST_DUE") {
      await database.subscription.update({
        where: { id: payment.subscriptionId },
        data: { status: "ACTIVE" },
      });
    }

    return updated as any;
  }

  async failPayment(paymentId: string, reason: string): Promise<Payment> {
    const payment = await database.payment.findFirst({
      where: { id: paymentId, state: "A" },
      include: { subscription: true },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    const updated = await database.payment.update({
      where: { id: paymentId },
      data: {
        status: "FAILED",
        failureReason: reason,
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    // Update subscription status to PAST_DUE
    await database.subscription.update({
      where: { id: payment.subscriptionId },
      data: { status: "PAST_DUE" },
    });

    return updated as any;
  }

  async refundPayment(
    paymentId: string,
    data: RefundPaymentInput
  ): Promise<Payment> {
    const payment = await database.payment.findFirst({
      where: { id: paymentId, state: "A" },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    if (payment.status !== "COMPLETED") {
      throw new Error("PAYMENT_NOT_COMPLETED");
    }

    const refundAmount = data.amount || Number(payment.amount);

    if (refundAmount > Number(payment.amount)) {
      throw new Error("REFUND_AMOUNT_EXCEEDS_PAYMENT");
    }

    // TODO: Process refund with payment gateway
    // Note: Prisma schema doesn't have refundedAmount and refundedAt fields
    // Store refund info in metadata
    const updated = await database.payment.update({
      where: { id: paymentId },
      data: {
        status: data.amount && data.amount < Number(payment.amount) ? "PARTIALLY_REFUNDED" : "REFUNDED",
        failureReason: data.reason,
        metadata: {
          ...(payment.metadata as any),
          refundedAmount: refundAmount,
          refundedAt: new Date().toISOString(),
        } as any,
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    return updated as any;
  }

  // =====================================================
  // INVOICE MANAGEMENT
  // =====================================================
  async createInvoice(data: CreateInvoiceInput): Promise<Invoice> {
    // Verify subscription exists
    const subscription = await database.subscription.findFirst({
      where: { id: data.subscriptionId, state: "A" },
    });

    if (!subscription) {
      throw new Error("SUBSCRIPTION_NOT_FOUND");
    }

    // Calculate total from items
    const itemsTotal = data.items.reduce((sum, item) => sum + item.total, 0);
    const total = itemsTotal + data.tax;

    const invoice = await database.invoice.create({
      data: {
        subscriptionId: data.subscriptionId,
        invoiceNumber: data.invoiceNumber,
        amount: itemsTotal,
        tax: data.tax,
        total: total,
        currency: data.currency,
        status: data.status,
        dueDate: data.dueDate || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
      include: {
        subscription: {
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
        },
      },
    });

    return invoice as any;
  }

  async getInvoiceById(id: string): Promise<Invoice | null> {
    const invoice = await database.invoice.findFirst({
      where: { id, state: "A" },
      include: {
        subscription: {
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
        },
      },
    });

    return invoice as any;
  }

  async getInvoicesBySubscription(
    subscriptionId: string,
    filters?: InvoiceQueryInput
  ): Promise<{
    invoices: Invoice[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      subscriptionId,
      state: "A",
      ...(filters?.status && { status: filters.status }),
    };

    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const [invoices, total] = await Promise.all([
      database.invoice.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          subscription: {
            include: { plan: true },
          },
        },
      }),
      database.invoice.count({ where }),
    ]);

    return {
      invoices: invoices as any,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getInvoicesByUser(
    userId: string,
    filters?: InvoiceQueryInput
  ): Promise<{
    invoices: Invoice[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters?.page || 1;
    const limit = filters?.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      subscription: {
        userId,
      },
      state: "A",
      ...(filters?.status && { status: filters.status }),
    };

    if (filters?.subscriptionId) {
      where.subscriptionId = filters.subscriptionId;
    }

    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const [invoices, total] = await Promise.all([
      database.invoice.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          subscription: {
            include: { plan: true },
          },
        },
      }),
      database.invoice.count({ where }),
    ]);

    return {
      invoices: invoices as any,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async updateInvoice(id: string, data: UpdateInvoiceInput): Promise<Invoice> {
    const invoice = await database.invoice.findFirst({
      where: { id, state: "A" },
    });

    if (!invoice) {
      throw new Error("INVOICE_NOT_FOUND");
    }

    const updated = await database.invoice.update({
      where: { id },
      data: {
        status: data.status,
        paidAt: data.paidAt,
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    return updated as any;
  }

  async markInvoiceAsPaid(
    invoiceId: string,
    paymentId: string
  ): Promise<Invoice> {
    const invoice = await database.invoice.findFirst({
      where: { id: invoiceId, state: "A" },
    });

    if (!invoice) {
      throw new Error("INVOICE_NOT_FOUND");
    }

    const payment = await database.payment.findFirst({
      where: { id: paymentId, state: "A" },
    });

    if (!payment) {
      throw new Error("PAYMENT_NOT_FOUND");
    }

    const updated = await database.invoice.update({
      where: { id: invoiceId },
      data: {
        status: "PAID",
        paidAt: new Date(),
      },
      include: {
        subscription: {
          include: { plan: true },
        },
      },
    });

    return updated as any;
  }

  async deleteInvoice(id: string): Promise<void> {
    const invoice = await database.invoice.findFirst({
      where: { id, state: "A" },
    });

    if (!invoice) {
      throw new Error("INVOICE_NOT_FOUND");
    }

    if (invoice.status === "PAID") {
      throw new Error("CANNOT_DELETE_PAID_INVOICE");
    }

    await database.invoice.update({
      where: { id },
      data: { state: "I" },
    });
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================
  async generateInvoiceNumber(): Promise<string> {
    const year = new Date().getFullYear();
    const count = await database.invoice.count({
      where: {
        invoiceNumber: {
          startsWith: `INV-${year}-`,
        },
      },
    });

    const number = String(count + 1).padStart(6, "0");
    return `INV-${year}-${number}`;
  }

  async checkOverdueInvoices(): Promise<{ count: number }> {
    const result = await database.invoice.updateMany({
      where: {
        dueDate: { lt: new Date() },
        status: { in: ["SENT", "DRAFT"] },
        state: "A",
      },
      data: {
        status: "OVERDUE",
      },
    });

    return { count: result.count };
  }
}

// =====================================================
// EXPORT SINGLETON
// =====================================================
export const paymentService = new PaymentService();
