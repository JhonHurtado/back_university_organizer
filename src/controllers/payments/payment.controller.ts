// =====================================================
// controllers/payments/payment.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { paymentService } from "@/services/payments/payment.service";
import { sendError, sendErrorValidation, sendSuccess } from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as paymentSchemas from "@/types/schemas/payments/payment.schemas";

// =====================================================
// PAYMENT CONTROLLERS
// =====================================================
export async function createPayment(req: Request, res: Response) {
  try {
    const data = paymentSchemas.createPaymentSchema.parse(req.body);
    const payment = await paymentService.createPayment(data);
    return sendSuccess({ res, code: 201, message: "Pago creado exitosamente", data: payment });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Suscripción no encontrada", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al crear pago", error: "SERVER_ERROR" });
  }
}

export async function getPaymentById(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const payment = await paymentService.getPaymentById(id);
    if (!payment) return sendError({ res, code: 404, message: "Pago no encontrado", error: "NOT_FOUND" });
    return sendSuccess({ res, message: "Pago obtenido exitosamente", data: payment });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al obtener pago", error: "SERVER_ERROR" });
  }
}

export async function getPaymentsByUser(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const filters = paymentSchemas.paymentQuerySchema.parse(req.query);
    const result = await paymentService.getPaymentsByUser(userId, filters);
    return sendSuccess({ res, message: "Pagos obtenidos exitosamente", data: result });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendError({ res, code: 500, message: "Error al obtener pagos", error: "SERVER_ERROR" });
  }
}

export async function updatePayment(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const data = paymentSchemas.updatePaymentSchema.parse(req.body);
    const payment = await paymentService.updatePayment(id, data);
    return sendSuccess({ res, message: "Pago actualizado exitosamente", data: payment });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Pago no encontrado", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al actualizar pago", error: "SERVER_ERROR" });
  }
}

export async function processPayment(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const payment = await paymentService.processPayment(id);
    return sendSuccess({ res, message: "Pago en proceso", data: payment });
  } catch (error: any) {
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Pago no encontrado", error: error.message });
    }
    if (error.message === "PAYMENT_ALREADY_PROCESSED") {
      return sendError({ res, code: 400, message: "El pago ya ha sido procesado", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al procesar pago", error: "SERVER_ERROR" });
  }
}

export async function refundPayment(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const data = paymentSchemas.refundPaymentSchema.parse(req.body);
    const payment = await paymentService.refundPayment(id, data);
    return sendSuccess({ res, message: "Reembolso procesado exitosamente", data: payment });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Pago no encontrado", error: error.message });
    }
    if (error.message === "PAYMENT_NOT_COMPLETED") {
      return sendError({ res, code: 400, message: "Solo se pueden reembolsar pagos completados", error: error.message });
    }
    if (error.message === "REFUND_AMOUNT_EXCEEDS_PAYMENT") {
      return sendError({ res, code: 400, message: "El monto del reembolso excede el monto del pago", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al procesar reembolso", error: "SERVER_ERROR" });
  }
}

// =====================================================
// INVOICE CONTROLLERS
// =====================================================
export async function createInvoice(req: Request, res: Response) {
  try {
    const data = paymentSchemas.createInvoiceSchema.parse(req.body);
    const invoice = await paymentService.createInvoice(data);
    return sendSuccess({ res, code: 201, message: "Factura creada exitosamente", data: invoice });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Suscripción no encontrada", error: error.message });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Pago no encontrado", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al crear factura", error: "SERVER_ERROR" });
  }
}

export async function getInvoiceById(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    const invoice = await paymentService.getInvoiceById(id);
    if (!invoice) return sendError({ res, code: 404, message: "Factura no encontrada", error: "NOT_FOUND" });
    return sendSuccess({ res, message: "Factura obtenida exitosamente", data: invoice });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al obtener factura", error: "SERVER_ERROR" });
  }
}

export async function getInvoicesByUser(req: Request, res: Response) {
  try {
    const userId = req.user?.id!;
    const filters = paymentSchemas.invoiceQuerySchema.parse(req.query);
    const result = await paymentService.getInvoicesByUser(userId, filters);
    return sendSuccess({ res, message: "Facturas obtenidas exitosamente", data: result });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendError({ res, code: 500, message: "Error al obtener facturas", error: "SERVER_ERROR" });
  }
}

export async function updateInvoice(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    const data = paymentSchemas.updateInvoiceSchema.parse(req.body);
    const invoice = await paymentService.updateInvoice(id, data);
    return sendSuccess({ res, message: "Factura actualizada exitosamente", data: invoice });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "INVOICE_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Factura no encontrada", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al actualizar factura", error: "SERVER_ERROR" });
  }
}

export async function markInvoiceAsPaid(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    const { paymentId } = req.body;
    const invoice = await paymentService.markInvoiceAsPaid(id, paymentId);
    return sendSuccess({ res, message: "Factura marcada como pagada", data: invoice });
  } catch (error: any) {
    if (error.message === "INVOICE_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Factura no encontrada", error: error.message });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Pago no encontrado", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al marcar factura como pagada", error: "SERVER_ERROR" });
  }
}

export async function deleteInvoice(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    await paymentService.deleteInvoice(id);
    return sendSuccess({ res, message: "Factura eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "INVOICE_NOT_FOUND") {
      return sendError({ res, code: 404, message: "Factura no encontrada", error: error.message });
    }
    if (error.message === "CANNOT_DELETE_PAID_INVOICE") {
      return sendError({ res, code: 400, message: "No se puede eliminar una factura pagada", error: error.message });
    }
    return sendError({ res, code: 500, message: "Error al eliminar factura", error: "SERVER_ERROR" });
  }
}

export async function generateInvoiceNumber(_req: Request, res: Response) {
  try {
    const invoiceNumber = await paymentService.generateInvoiceNumber();
    return sendSuccess({ res, message: "Número de factura generado", data: { invoiceNumber } });
  } catch (error: any) {
    return sendError({ res, code: 500, message: "Error al generar número de factura", error: "SERVER_ERROR" });
  }
}

// =====================================================
// WEBHOOK CONTROLLER
// =====================================================
export async function handlePaymentWebhook(req: Request, res: Response) {
  try {
    const data = paymentSchemas.paymentWebhookSchema.parse(req.body);

    // TODO: Verify webhook signature
    // const isValid = verifyWebhookSignature(data.signature, req.body);
    // if (!isValid) {
    //   return sendError({ res, code: 401, message: "Firma inválida", error: "INVALID_SIGNATURE" });
    // }

    // Process webhook event
    switch (data.event) {
      case "payment.completed":
        if (data.paymentId && data.transactionId) {
          await paymentService.completePayment(data.paymentId, data.transactionId);
        }
        break;

      case "payment.failed":
        if (data.paymentId) {
          await paymentService.failPayment(
            data.paymentId,
            (data.metadata?.reason as string) || "Payment failed"
          );
        }
        break;

      case "payment.refunded":
        // Handle refund event
        break;

      default:
        console.log(`Unhandled webhook event: ${data.event}`);
    }

    return sendSuccess({ res, message: "Webhook procesado exitosamente" });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendErrorValidation({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    console.error("Webhook error:", error);
    return sendError({ res, code: 500, message: "Error al procesar webhook", error: "SERVER_ERROR" });
  }
}
