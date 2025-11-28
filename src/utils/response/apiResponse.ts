// =====================================================
// utils/apiResponse.ts
// =====================================================
import type { Response } from "express";

interface SuccessParams<T> {
  res: Response;
  data?: T;
  message?: string;
  code?: number;
}

interface ErrorParams {
  res: Response;
  message?: string;
  code?: number;
  error?: string;
  data?: any;
}

interface ValidationErrorParams {
  res: Response;
  message?: string;
  code?: number;
  errors: Record<string, string | string[]>;
}

// =====================================================
// SUCCESS
// =====================================================
export function sendSuccess<T>({
  res,
  data = null as T,
  message = "Operación exitosa",
  code = 200,
}: SuccessParams<T>): Response {
  return res.status(code).json({
    success: true,
    message,
    data,
  });
}

// =====================================================
// ERROR
// =====================================================
export function sendError({
  res,
  message = "Ha ocurrido un error",
  code = 400,
  error = "BAD_REQUEST",
  data = null,
}: ErrorParams): Response {
  return res.status(code).json({
    success: false,
    message,
    error,
    data,
  });
}

// =====================================================
// VALIDATION ERROR
// =====================================================
export function sendErrorValidation({
  res,
  message = "Error de validación",
  code = 422,
  errors,
}: ValidationErrorParams): Response {
  return res.status(code).json({
    success: false,
    message,
    error: "VALIDATION_ERROR",
    errors,
  });
}