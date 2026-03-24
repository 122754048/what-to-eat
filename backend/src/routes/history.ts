/**
 * 历史记录路由
 * @module routes/history
 */
import { Hono } from 'hono';
import { getHistory, giveFeedback } from '../services/history.service';
import { error, ErrorCodes } from '../utils/response';

export const historyRouter = new Hono();

/**
 * GET /history - 获取推荐历史
 */
historyRouter.get('/history', async (c) => {
  const userId = c.req.header('X-User-ID') ?? 'anonymous';
  const page = parseInt(c.req.query('page') ?? '1', 10);
  const pageSize = Math.min(parseInt(c.req.query('pageSize') ?? '20', 10), 100);

  const result = await getHistory(userId, page, pageSize);
  return c.json({ code: 0, message: 'ok', data: result });
});

/**
 * POST /history/:historyId/feedback - 反馈推荐结果
 */
historyRouter.post('/history/:historyId/feedback', async (c) => {
  const historyId = parseInt(c.req.param('historyId'), 10);
  const userId = c.req.header('X-User-ID') ?? 'anonymous';
  const body = await c.req.json().catch(() => null);

  if (isNaN(historyId) || body === null || typeof body.liked !== 'number') {
    return c.json(error(ErrorCodes.PARAM_INVALID, '参数错误'), 400);
  }

  const success = await giveFeedback(historyId, userId, body.liked);
  if (!success) {
    return c.json(error(ErrorCodes.NOT_FOUND, '历史记录不存在'), 404);
  }

  return c.json({ code: 0, message: 'ok' });
});
