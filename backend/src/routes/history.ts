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
  const page = Math.max(1, parseInt(c.req.query('page') ?? '1', 10));
  const pageSize = Math.min(Math.max(1, parseInt(c.req.query('pageSize') ?? '20', 10)), 100);

  const result = await getHistory(userId, page, pageSize);
  return c.json({ code: 0, message: 'ok', data: result });
});

/**
 * POST /history/:historyId/feedback - 反馈推荐结果
 * 注意：Firestore 使用字符串 ID
 */
historyRouter.post('/history/:historyId/feedback', async (c) => {
  const historyId = c.req.param('historyId');
  const userId = c.req.header('X-User-ID') ?? 'anonymous';
  const body = await c.req.json().catch(() => null);

  if (!historyId || historyId.trim() === '') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'historyId 不能为空'), 400);
  }

  if (body === null || typeof body.liked !== 'number' || body.liked < -1 || body.liked > 1) {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'liked 必须是 -1、0 或 1'), 400);
  }

  const success = await giveFeedback(historyId, userId, body.liked);
  if (!success) {
    return c.json(error(ErrorCodes.NOT_FOUND, '历史记录不存在或无权修改'), 404);
  }

  return c.json({ code: 0, message: 'ok' });
});
