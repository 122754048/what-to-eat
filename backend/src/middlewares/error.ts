/**
 * 统一错误处理中间件
 * @module middlewares/error
 */
import type { Hono } from 'hono';
import { error, ErrorCodes } from '../utils/response';

export function setErrorHandler(app: Hono) {
  app.onError((err, c) => {
    console.error('[Error]', err.message, err.stack);
    return c.json(
      error(ErrorCodes.INTERNAL_ERROR, '服务端内部错误'),
      500
    );
  });
}
