/**
 * CORS 中间件
 * @module middlewares/cors
 */
import type { Hono } from 'hono';

export function setCors(app: Hono) {
  app.use('*', async (c, next) => {
    await next();
    c.res.headers.set('Access-Control-Allow-Origin', '*');
    c.res.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    c.res.headers.set('Access-Control-Allow-Headers', 'Content-Type, X-User-ID');
  });
}
