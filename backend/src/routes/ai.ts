/**
 * AI 路由
 * @module routes/ai
 *
 * V2.0 Phase 1：Mock API，支持 mealContext + allergies
 * 响应格式：{ name, reason, calories, pairings, imageUrl }
 */
import { Hono } from 'hono';
import { generateDish, GenerateDishInput } from '../services/ai-dish.service';
import { error, ErrorCodes } from '../utils/response';

export const aiRouter = new Hono();

/**
 * POST /ai/dish - AI生成菜品
 *
 * 请求体：
 * {
 *   "cuisineId": "chinese_sichuan",   // 菜系ID
 *   "mealContext": "午餐",            // 餐食场景（可选）
 *   "allergies": ["虾", "花生"]       // 过敏原过滤（可选）
 * }
 *
 * 响应：
 * {
 *   "code": 0,
 *   "data": {
 *     "dish": {
 *       "name": "宫保鸡丁",
 *       "reason": "经典川菜代表，麻辣鲜香！",
 *       "calories": "300-400",
 *       "pairings": {
 *         "dishes": ["米饭"],
 *         "drinks": ["柠檬茶", "酸梅汤"]
 *       },
 *       "imageUrl": "https://..."
 *     }
 *   }
 * }
 */
aiRouter.post('/ai/dish', async (c) => {
  const body = await c.req.json().catch(() => null);

  if (!body || typeof body.cuisineId !== 'string') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'cuisineId 不能为空'), 400);
  }

  const input: GenerateDishInput = {
    cuisineId: body.cuisineId,
    mealContext: typeof body.mealContext === 'string' ? body.mealContext : undefined,
    allergies: Array.isArray(body.allergies) ? body.allergies : [],
  };

  try {
    const dish = await generateDish(input);
    return c.json({ code: 0, message: 'ok', data: { dish } });
  } catch (err) {
    console.error('[AI Dish]', err);
    return c.json(error(ErrorCodes.INTERNAL_ERROR, 'AI生成失败'), 500);
  }
});

/**
 * POST /ai/reason - AI生成推荐理由
 *
 * 请求体：
 * {
 *   "dishName": "宫保鸡丁",
 *   "cuisineName": "川菜"
 * }
 *
 * 响应：
 * {
 *   "code": 0,
 *   "data": {
 *     "reason": "经典川菜代表，麻辣鲜香！"
 *   }
 * }
 */
aiRouter.post('/ai/reason', async (c) => {
  const body = await c.req.json().catch(() => null);

  if (!body || typeof body.dishName !== 'string') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'dishName 不能为空'), 400);
  }

  const { generateReason } = await import('../services/ai-reason.service');
  const reason = await generateReason({
    dishName: body.dishName,
    cuisineName: typeof body.cuisineName === 'string' ? body.cuisineName : undefined,
  });

  return c.json({ code: 0, message: 'ok', data: { reason } });
});
