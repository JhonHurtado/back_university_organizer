// =====================================================
// controllers/payments/payment.controller.ts
// =====================================================
import type { Request, Response } from "express";
import { paymentService } from "@/services/payments/payment.service";
import {
  sendSuccess,
  sendCreated,
  sendNotFound,
  sendBadRequest,
  sendServerError,
  sendValidationError,
} from "@/utils/response/apiResponse";
import { ZodError } from "zod";
import * as paymentSchemas from "@/types/schemas/payments/payment.schemas";

// =====================================================
// PAYMENT CONTROLLERS
// =====================================================
export async function createPayment(req: Request, res: Response) {
  try {
    const data = paymentSchemas.createPaymentSchema.parse(req.body);
    const payment = await paymentService.createPayment(data);
    return sendCreated({ res, message: "Pago creado exitosamente", data: payment });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    return sendServerError({ res, message: "Error al crear pago" });
  }
}

export async function getPaymentById(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const payment = await paymentService.getPaymentById(id);
    if (!payment) return sendNotFound({ res, message: "Pago no encontrado" });
    return sendSuccess({ res, message: "Pago obtenido exitosamente", data: payment });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener pago" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendServerError({ res, message: "Error al obtener pagos" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Pago no encontrado" });
    }
    return sendServerError({ res, message: "Error al actualizar pago" });
  }
}

export async function processPayment(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.paymentIdSchema.parse(req.params);
    const payment = await paymentService.processPayment(id);
    return sendSuccess({ res, message: "Pago en proceso", data: payment });
  } catch (error: any) {
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Pago no encontrado" });
    }
    if (error.message === "PAYMENT_ALREADY_PROCESSED") {
      return sendBadRequest({ res, message: "El pago ya ha sido procesado" });
    }
    return sendServerError({ res, message: "Error al procesar pago" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Pago no encontrado" });
    }
    if (error.message === "PAYMENT_NOT_COMPLETED") {
      return sendBadRequest({ res, message: "Solo se pueden reembolsar pagos completados" });
    }
    if (error.message === "REFUND_AMOUNT_EXCEEDS_PAYMENT") {
      return sendBadRequest({ res, message: "El monto del reembolso excede el monto del pago" });
    }
    return sendServerError({ res, message: "Error al procesar reembolso" });
  }
}

// =====================================================
// INVOICE CONTROLLERS
// =====================================================
export async function createInvoice(req: Request, res: Response) {
  try {
    const data = paymentSchemas.createInvoiceSchema.parse(req.body);
    const invoice = await paymentService.createInvoice(data);
    return sendCreated({ res, message: "Factura creada exitosamente", data: invoice });
  } catch (error: any) {
    if (error instanceof ZodError) {
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "SUBSCRIPTION_NOT_FOUND") {
      return sendNotFound({ res, message: "Suscripción no encontrada" });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Pago no encontrado" });
    }
    return sendServerError({ res, message: "Error al crear factura" });
  }
}

export async function getInvoiceById(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    const invoice = await paymentService.getInvoiceById(id);
    if (!invoice) return sendNotFound({ res, message: "Factura no encontrada" });
    return sendSuccess({ res, message: "Factura obtenida exitosamente", data: invoice });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al obtener factura" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    return sendServerError({ res, message: "Error al obtener facturas" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    if (error.message === "INVOICE_NOT_FOUND") {
      return sendNotFound({ res, message: "Factura no encontrada" });
    }
    return sendServerError({ res, message: "Error al actualizar factura" });
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
      return sendNotFound({ res, message: "Factura no encontrada" });
    }
    if (error.message === "PAYMENT_NOT_FOUND") {
      return sendNotFound({ res, message: "Pago no encontrado" });
    }
    return sendServerError({ res, message: "Error al marcar factura como pagada" });
  }
}

export async function deleteInvoice(req: Request, res: Response) {
  try {
    const { id } = paymentSchemas.invoiceIdSchema.parse(req.params);
    await paymentService.deleteInvoice(id);
    return sendSuccess({ res, message: "Factura eliminada exitosamente" });
  } catch (error: any) {
    if (error.message === "INVOICE_NOT_FOUND") {
      return sendNotFound({ res, message: "Factura no encontrada" });
    }
    if (error.message === "CANNOT_DELETE_PAID_INVOICE") {
      return sendBadRequest({ res, message: "No se puede eliminar una factura pagada" });
    }
    return sendServerError({ res, message: "Error al eliminar factura" });
  }
}

export async function generateInvoiceNumber(_req: Request, res: Response) {
  try {
    const invoiceNumber = await paymentService.generateInvoiceNumber();
    return sendSuccess({ res, message: "Número de factura generado", data: { invoiceNumber } });
  } catch (error: any) {
    return sendServerError({ res, message: "Error al generar número de factura" });
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
    //   return sendUnauthorized({ res, message: "Firma inválida" });
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
      return sendValidationError({ res, errors: error.issues.reduce((acc, err) => ({ ...acc, [err.path.join(".")]: err.message }), {}) });
    }
    console.error("Webhook error:", error);
    return sendServerError({ res, message: "Error al procesar webhook" });
  }
}
