/**
 * 菜系列表路由
 * @module routes/cuisines
 */
import { Hono } from 'hono';
import { getCuisines } from '../services/cuisine.service';

export const cuisinesRouter = new Hono();

/**
 * GET /cuisines - 获取菜系列表
 */
cuisinesRouter.get('/', async (c) => {
  const cuisines = await getCuisines();
  return c.json({ code: 0, message: 'ok', data: { cuisines } });
});
