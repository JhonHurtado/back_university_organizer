// =====================================================
// types/schemas/payments/payment.schemas.ts
// =====================================================
import { z } from "zod";

// =====================================================
// ENUMS
// =====================================================
export const PaymentStatusSchema = z.enum([
  "PENDING",
  "PROCESSING",
  "COMPLETED",
  "FAILED",
  "REFUNDED",
  "PARTIALLY_REFUNDED",
  "DISPUTED",
]);

export const PaymentMethodSchema = z.enum([
  "CREDIT_CARD",
  "DEBIT_CARD",
  "PAYPAL",
  "BANK_TRANSFER",
  "CRYPTO",
  "OTHER",
]);

export const InvoiceStatusSchema = z.enum([
  "DRAFT",
  "SENT",
  "PAID",
  "OVERDUE",
  "CANCELLED",
]);

// =====================================================
// PAYMENT SCHEMAS
// =====================================================
export const createPaymentSchema = z.object({
  subscriptionId: z.string().uuid("ID de suscripción inválido"),
  amount: z.number().positive("El monto debe ser mayor a 0"),
  currency: z.string().length(3, "La moneda debe tener 3 caracteres (ISO 4217)").default("USD"),
  paymentMethod: PaymentMethodSchema,
  status: PaymentStatusSchema.default("PENDING"),
  transactionId: z.string().optional(),
  metadata: z.record(z.string(), z.any()).optional(),
});

export const updatePaymentSchema = z.object({
  status: PaymentStatusSchema.optional(),
  transactionId: z.string().optional(),
  failureReason: z.string().optional(),
  metadata: z.record(z.string(), z.any()).optional(),
  processedAt: z.coerce.date().optional(),
});

export const paymentIdSchema = z.object({
  id: z.string().uuid("ID de pago inválido"),
});

export const refundPaymentSchema = z.object({
  amount: z.number().positive("El monto a reembolsar debe ser mayor a 0").optional(),
  reason: z.string().min(10, "La razón debe tener al menos 10 caracteres"),
});

// =====================================================
// INVOICE SCHEMAS
// =====================================================
export const createInvoiceSchema = z.object({
  subscriptionId: z.string().uuid("ID de suscripción inválido"),
  paymentId: z.string().uuid("ID de pago inválido").optional(),
  invoiceNumber: z.string().min(1, "El número de factura es requerido"),
  amount: z.number().positive("El monto debe ser mayor a 0"),
  tax: z.number().nonnegative("El impuesto no puede ser negativo").default(0),
  currency: z.string().length(3).default("USD"),
  status: InvoiceStatusSchema.default("DRAFT"),
  issueDate: z.coerce.date().optional(),
  dueDate: z.coerce.date().optional(),
  items: z.array(
    z.object({
      description: z.string().min(1, "La descripción es requerida"),
      quantity: z.number().int().positive("La cantidad debe ser mayor a 0").default(1),
      unitPrice: z.number().positive("El precio unitario debe ser mayor a 0"),
      total: z.number().positive("El total debe ser mayor a 0"),
    })
  ).min(1, "Debe incluir al menos un item"),
});

export const updateInvoiceSchema = z.object({
  status: InvoiceStatusSchema.optional(),
  paymentId: z.string().uuid().optional(),
  paidAt: z.coerce.date().optional(),
  items: z.array(
    z.object({
      description: z.string().min(1),
      quantity: z.number().int().positive().default(1),
      unitPrice: z.number().positive(),
      total: z.number().positive(),
    })
  ).optional(),
});

export const invoiceIdSchema = z.object({
  id: z.string().uuid("ID de factura inválido"),
});

// =====================================================
// WEBHOOK SCHEMAS
// =====================================================
export const paymentWebhookSchema = z.object({
  event: z.string().min(1, "El evento es requerido"),
  paymentId: z.string().optional(),
  transactionId: z.string().optional(),
  status: PaymentStatusSchema.optional(),
  amount: z.number().optional(),
  currency: z.string().optional(),
  metadata: z.record(z.string(), z.any()).optional(),
  signature: z.string().min(1, "La firma es requerida"),
});

// =====================================================
// QUERY SCHEMAS
// =====================================================
export const paymentQuerySchema = z.object({
  subscriptionId: z.string().uuid().optional(),
  status: PaymentStatusSchema.optional(),
  paymentMethod: PaymentMethodSchema.optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export const invoiceQuerySchema = z.object({
  subscriptionId: z.string().uuid().optional(),
  status: InvoiceStatusSchema.optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

// =====================================================
// TYPE EXPORTS
// =====================================================
export type CreatePaymentInput = z.infer<typeof createPaymentSchema>;
export type UpdatePaymentInput = z.infer<typeof updatePaymentSchema>;
export type RefundPaymentInput = z.infer<typeof refundPaymentSchema>;
export type CreateInvoiceInput = z.infer<typeof createInvoiceSchema>;
export type UpdateInvoiceInput = z.infer<typeof updateInvoiceSchema>;
export type PaymentWebhookInput = z.infer<typeof paymentWebhookSchema>;
export type PaymentQueryInput = z.infer<typeof paymentQuerySchema>;
export type InvoiceQueryInput = z.infer<typeof invoiceQuerySchema>;
