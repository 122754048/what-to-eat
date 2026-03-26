/**
 * Hono 应用实例
 * @module app
 */
import { Hono } from 'hono';
import { cuisinesRouter } from './routes/cuisines';
import { recommendRouter } from './routes/recommend';
import { dishesRouter } from './routes/dishes';
import { historyRouter } from './routes/history';
import { aiRouter } from './routes/ai';

export const app = new Hono();

// 注册路由（路径相对于 /api/v1，由 index.ts 统一挂载）
app.route('/cuisines', cuisinesRouter);
app.route('/', recommendRouter);   // /cuisines/:cuisineId/recommend
app.route('/dishes', dishesRouter);
app.route('/history', historyRouter);
app.route('/ai', aiRouter);

// 健康检查
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));
