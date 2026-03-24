/**
 * 统一响应格式工具
 * @module utils/response
 */

export const SUCCESS_CODE = 0;

export const ErrorCodes = {
  PARAM_INVALID: 40001,
  NOT_FOUND: 40401,
  TOO_MANY_REQUESTS: 42901,
  INTERNAL_ERROR: 50001,
  AI_UNAVAILABLE: 50301,
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

/**
 * 成功响应
 */
export function success<T>(data: T) {
  return {
    code: SUCCESS_CODE,
    message: 'ok',
    data,
  };
}

/**
 * 错误响应
 */
export function error(code: ErrorCode, message: string, details?: unknown) {
  return {
    code,
    message,
    details: details ?? null,
  };
}
