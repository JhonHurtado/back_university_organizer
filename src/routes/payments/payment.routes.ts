// =====================================================
// routes/payments/payment.routes.ts
// =====================================================
import { Router } from "express";
import * as paymentController from "../../controllers/payments/payment.controller";
import { requireAuth } from "../../middleware/auth/auth.middleware";

const router = Router();

// =====================================================
// PAYMENT ROUTES
// =====================================================
// Create payment
router.post("/", requireAuth, paymentController.createPayment);

// Get user's payments
router.get("/", requireAuth, paymentController.getPaymentsByUser);

// Get payment by ID
router.get("/:id", requireAuth, paymentController.getPaymentById);

// Update payment
router.put("/:id", requireAuth, paymentController.updatePayment);

// Process payment
router.post("/:id/process", requireAuth, paymentController.processPayment);

// Refund payment
router.post("/:id/refund", requireAuth, paymentController.refundPayment);

// =====================================================
// INVOICE ROUTES
// =====================================================
// Create invoice
router.post("/invoices", requireAuth, paymentController.createInvoice);

// Get user's invoices
router.get("/invoices", requireAuth, paymentController.getInvoicesByUser);

// Generate invoice number
router.get("/invoices/generate-number", requireAuth, paymentController.generateInvoiceNumber);

// Get invoice by ID
router.get("/invoices/:id", requireAuth, paymentController.getInvoiceById);

// Update invoice
router.put("/invoices/:id", requireAuth, paymentController.updateInvoice);

// Mark invoice as paid
router.post("/invoices/:id/mark-paid", requireAuth, paymentController.markInvoiceAsPaid);

// Delete invoice
router.delete("/invoices/:id", requireAuth, paymentController.deleteInvoice);

// =====================================================
// WEBHOOK ROUTES (No auth required - validated by signature)
// =====================================================
router.post("/webhooks", paymentController.handlePaymentWebhook);

export default router;
