/**
 * 请求日志中间件
 * @module middlewares/logger
 */
import type { Hono } from 'hono';

export function setLogger(app: Hono) {
  app.use('*', async (c, next) => {
    const start = Date.now();
    await next();
    const duration = Date.now() - start;
    const log = `[${new Date().toISOString()}] ${c.req.method} ${c.req.path} ${c.res.status} - ${duration}ms`;
    console.log(log);
  });
}
