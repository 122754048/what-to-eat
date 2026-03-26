/**
 * 菜品详情路由
 * @module routes/dishes
 */
import { Hono } from 'hono';
import { getDishDetail } from '../services/dish.service';
import { error, ErrorCodes } from '../utils/response';

export const dishesRouter = new Hono();

/**
 * GET /:dishId - 获取菜品详情
 */
dishesRouter.get('/:dishId', async (c) => {
  const dishId = c.req.param('dishId');

  const dish = await getDishDetail(dishId);
  if (!dish) {
    return c.json(error(ErrorCodes.NOT_FOUND, '菜品不存在'), 404);
  }

  return c.json({ code: 0, message: 'ok', data: { dish } });
});
