/**
 * Hono 应用实例
 * @module app
 */
import { Hono } from 'hono';
import { cuisinesRouter } from './routes/cuisines';
import { recommendRouter } from './routes/recommend';
import { dishesRouter } from './routes/dishes';
import { historyRouter } from './routes/history';

export const app = new Hono();

// 注册路由
app.route('/api/v1/cuisines', cuisinesRouter);
app.route('/api/v1', recommendRouter);
app.route('/api/v1', dishesRouter);
app.route('/api/v1', historyRouter);

// 健康检查
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));
