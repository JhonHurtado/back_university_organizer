// =====================================================
// API Response Utilities
// Standardized response format for all API endpoints
// =====================================================
import type { Response } from "express";

// =====================================================
// TYPES & INTERFACES
// =====================================================

/**
 * Standard API success response structure
 */
export interface ApiSuccessResponse<T = any> {
  success: true;
  message: string;
  data: T;
  meta?: PaginationMeta;
}

/**
 * Standard API error response structure
 */
export interface ApiErrorResponse {
  success: false;
  message: string;
  error: string;
  data?: any;
  errors?: Record<string, string | string[]>;
}

/**
 * Pagination metadata
 */
export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

/**
 * Parameters for success responses
 */
interface SuccessParams<T> {
  res: Response;
  data?: T;
  message?: string;
  statusCode?: number;
  meta?: PaginationMeta;
}

/**
 * Parameters for error responses
 */
interface ErrorParams {
  res: Response;
  message?: string;
  statusCode?: number;
  error?: string;
  data?: any;
}

/**
 * Parameters for validation error responses
 */
interface ValidationErrorParams {
  res: Response;
  message?: string;
  errors: Record<string, string | string[]>;
}

// =====================================================
// HTTP STATUS CODES
// =====================================================
export const HttpStatus = {
  // Success
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,

  // Client Errors
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,

  // Server Errors
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

// =====================================================
// STANDARD ERROR CODES
// =====================================================
export const ErrorCode = {
  // Authentication & Authorization
  INVALID_CREDENTIALS: "INVALID_CREDENTIALS",
  INVALID_TOKEN: "INVALID_TOKEN",
  TOKEN_EXPIRED: "TOKEN_EXPIRED",
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  EMAIL_EXISTS: "EMAIL_EXISTS",
  ACCOUNT_DISABLED: "ACCOUNT_DISABLED",

  // Validation
  VALIDATION_ERROR: "VALIDATION_ERROR",
  MISSING_FIELDS: "MISSING_FIELDS",
  INVALID_INPUT: "INVALID_INPUT",

  // Resources
  NOT_FOUND: "NOT_FOUND",
  ALREADY_EXISTS: "ALREADY_EXISTS",
  CONFLICT: "CONFLICT",

  // Server
  SERVER_ERROR: "SERVER_ERROR",
  DATABASE_ERROR: "DATABASE_ERROR",
  SERVICE_UNAVAILABLE: "SERVICE_UNAVAILABLE",

  // Rate Limiting
  TOO_MANY_REQUESTS: "TOO_MANY_REQUESTS",
} as const;

// =====================================================
// SUCCESS RESPONSES
// =====================================================

/**
 * Send a successful response (200 OK)
 * @example
 * return sendSuccess({ res, data: user, message: "User retrieved successfully" });
 */
export function sendSuccess<T>({
  res,
  data = null as T,
  message = "Operación exitosa",
  statusCode = HttpStatus.OK,
  meta,
}: SuccessParams<T>): Response<ApiSuccessResponse<T>> {
  const response: ApiSuccessResponse<T> = {
    success: true,
    message,
    data,
  };

  if (meta) {
    response.meta = meta;
  }

  return res.status(statusCode).json(response);
}

/**
 * Send a resource created response (201 CREATED)
 * @example
 * return sendCreated({ res, data: newUser, message: "User created successfully" });
 */
export function sendCreated<T>({
  res,
  data = null as T,
  message = "Recurso creado exitosamente",
  meta,
}: Omit<SuccessParams<T>, "statusCode">): Response<ApiSuccessResponse<T>> {
  return sendSuccess({ res, data, message, statusCode: HttpStatus.CREATED, meta });
}

/**
 * Send a no content response (204 NO CONTENT)
 * @example
 * return sendNoContent({ res });
 */
export function sendNoContent({ res }: { res: Response }): Response {
  return res.status(HttpStatus.NO_CONTENT).send();
}

/**
 * Send a paginated response
 * @example
 * return sendPaginated({
 *   res,
 *   data: users,
 *   total: 100,
 *   page: 1,
 *   limit: 10,
 *   message: "Users retrieved successfully"
 * });
 */
export function sendPaginated<T>({
  res,
  data,
  total,
  page,
  limit,
  message = "Datos recuperados exitosamente",
}: {
  res: Response;
  data: T;
  total: number;
  page: number;
  limit: number;
  message?: string;
}): Response<ApiSuccessResponse<T>> {
  const totalPages = Math.ceil(total / limit);
  const meta: PaginationMeta = {
    total,
    page,
    limit,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1,
  };

  return sendSuccess({ res, data, message, meta });
}

// =====================================================
// ERROR RESPONSES
// =====================================================

/**
 * Send a generic error response
 * @example
 * return sendError({ res, message: "Something went wrong", statusCode: 400, error: "BAD_REQUEST" });
 */
export function sendError({
  res,
  message = "Ha ocurrido un error",
  statusCode = HttpStatus.BAD_REQUEST,
  error = ErrorCode.SERVER_ERROR,
  data = null,
}: ErrorParams): Response<ApiErrorResponse> {
  return res.status(statusCode).json({
    success: false,
    message,
    error,
    data,
  });
}

/**
 * Send a validation error response (422 UNPROCESSABLE ENTITY)
 * @example
 * return sendValidationError({
 *   res,
 *   errors: { email: "Email is required", password: "Password must be at least 8 characters" }
 * });
 */
export function sendValidationError({
  res,
  message = "Error de validación",
  errors,
}: ValidationErrorParams): Response<ApiErrorResponse> {
  return res.status(HttpStatus.UNPROCESSABLE_ENTITY).json({
    success: false,
    message,
    error: ErrorCode.VALIDATION_ERROR,
    errors,
  });
}

/**
 * Send a not found error response (404 NOT FOUND)
 * @example
 * return sendNotFound({ res, message: "User not found" });
 */
export function sendNotFound({
  res,
  message = "Recurso no encontrado",
  data = null,
}: Omit<ErrorParams, "statusCode" | "error">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.NOT_FOUND,
    error: ErrorCode.NOT_FOUND,
    data,
  });
}

/**
 * Send an unauthorized error response (401 UNAUTHORIZED)
 * @example
 * return sendUnauthorized({ res, message: "Invalid credentials" });
 */
export function sendUnauthorized({
  res,
  message = "No autorizado",
  error = ErrorCode.UNAUTHORIZED,
}: Omit<ErrorParams, "statusCode" | "data">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.UNAUTHORIZED,
    error,
  });
}

/**
 * Send a forbidden error response (403 FORBIDDEN)
 * @example
 * return sendForbidden({ res, message: "You don't have permission to access this resource" });
 */
export function sendForbidden({
  res,
  message = "Acceso prohibido",
}: Omit<ErrorParams, "statusCode" | "error" | "data">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.FORBIDDEN,
    error: ErrorCode.FORBIDDEN,
  });
}

/**
 * Send a conflict error response (409 CONFLICT)
 * @example
 * return sendConflict({ res, message: "Email already exists" });
 */
export function sendConflict({
  res,
  message = "Conflicto con el recurso existente",
  data = null,
}: Omit<ErrorParams, "statusCode" | "error">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.CONFLICT,
    error: ErrorCode.CONFLICT,
    data,
  });
}

/**
 * Send a bad request error response (400 BAD REQUEST)
 * @example
 * return sendBadRequest({ res, message: "Invalid request parameters" });
 */
export function sendBadRequest({
  res,
  message = "Solicitud inválida",
  data = null,
}: Omit<ErrorParams, "statusCode" | "error">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.BAD_REQUEST,
    error: ErrorCode.INVALID_INPUT,
    data,
  });
}

/**
 * Send a server error response (500 INTERNAL SERVER ERROR)
 * @example
 * return sendServerError({ res, message: "An unexpected error occurred" });
 */
export function sendServerError({
  res,
  message = "Error interno del servidor",
  data = null,
}: Omit<ErrorParams, "statusCode" | "error">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
    error: ErrorCode.SERVER_ERROR,
    data,
  });
}

/**
 * Send a too many requests error response (429 TOO MANY REQUESTS)
 * @example
 * return sendTooManyRequests({ res, message: "Rate limit exceeded" });
 */
export function sendTooManyRequests({
  res,
  message = "Demasiadas solicitudes",
}: Omit<ErrorParams, "statusCode" | "error" | "data">): Response<ApiErrorResponse> {
  return sendError({
    res,
    message,
    statusCode: HttpStatus.TOO_MANY_REQUESTS,
    error: ErrorCode.TOO_MANY_REQUESTS,
  });
}

// =====================================================
// UTILITY FUNCTIONS
// =====================================================

/**
 * Calculate pagination metadata
 * @example
 * const meta = calculatePagination(100, 1, 10);
 */
export function calculatePagination(
  total: number,
  page: number,
  limit: number
): PaginationMeta {
  const totalPages = Math.ceil(total / limit);
  return {
    total,
    page,
    limit,
    totalPages,
    hasNextPage: page < totalPages,
    hasPrevPage: page > 1,
  };
}

/**
 * Parse pagination query parameters
 * @example
 * const { page, limit } = parsePaginationParams(req.query);
 */
export function parsePaginationParams(query: any): { page: number; limit: number } {
  const page = Math.max(1, parseInt(query.page as string) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit as string) || 10));
  return { page, limit };
}
