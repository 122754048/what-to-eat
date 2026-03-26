/**
 * 随机推荐路由
 * @module routes/recommend
 */
import { Hono } from 'hono';
import { recommendDish } from '../services/recommend.service';
import { error, ErrorCodes } from '../utils/response';

export const recommendRouter = new Hono();

/**
 * POST /cuisines/:cuisineId/recommend - 随机推荐菜品
 */
recommendRouter.post('/cuisines/:cuisineId/recommend', async (c) => {
  const cuisineId = c.req.param('cuisineId');

  // 参数校验
  if (!cuisineId || cuisineId.trim() === '') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'cuisineId 不能为空'), 400);
  }

  const userId = c.req.header('X-User-ID') ?? 'anonymous';
  const body = await c.req.json().catch(() => ({}));
  const excludePrevious = body.excludePrevious !== false;

  const result = await recommendDish(cuisineId, userId, excludePrevious);

  if (!result) {
    return c.json(error(ErrorCodes.NOT_FOUND, '菜系不存在或暂无菜品'), 404);
  }

  return c.json({ code: 0, message: 'ok', data: { dish: result } });
});
