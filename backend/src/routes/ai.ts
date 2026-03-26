/**
 * AI 路由
 * @module routes/ai
 *
 * V2.0 新增：AI 动态生成菜品 API
 * 策略：Mock优先，真实AI等凭证到位后切换
 */
import { Hono } from 'hono';
import { generateDish, GenerateDishInput } from '../services/ai-dish.service';
import { generateReason, GenerateReasonInput } from '../services/ai-reason.service';
import { error, ErrorCodes } from '../utils/response';

export const aiRouter = new Hono();

/**
 * POST /ai/dish - AI生成菜品
 *
 * 请求体：
 * {
 *   "cuisineId": "chinese_sichuan",   // 菜系ID
 *   "dietaryRestrictions": ["不辣", "少油"], // 忌口过滤（可选）
 *   "mood": "想吃辣的"                  // 心情/偏好（可选）
 * }
 */
aiRouter.post('/ai/dish', async (c) => {
  const body = await c.req.json().catch(() => null);

  if (!body || typeof body.cuisineId !== 'string') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'cuisineId 不能为空'), 400);
  }

  const input: GenerateDishInput = {
    cuisineId: body.cuisineId,
    dietaryRestrictions: Array.isArray(body.dietaryRestrictions) ? body.dietaryRestrictions : [],
    mood: typeof body.mood === 'string' ? body.mood : undefined,
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
 */
aiRouter.post('/ai/reason', async (c) => {
  const body = await c.req.json().catch(() => null);

  if (!body || typeof body.dishName !== 'string') {
    return c.json(error(ErrorCodes.PARAM_INVALID, 'dishName 不能为空'), 400);
  }

  const input: GenerateReasonInput = {
    dishName: body.dishName,
    cuisineName: typeof body.cuisineName === 'string' ? body.cuisineName : undefined,
  };

  try {
    const reason = await generateReason(input);
    return c.json({ code: 0, message: 'ok', data: { reason } });
  } catch (err) {
    console.error('[AI Reason]', err);
    return c.json(error(ErrorCodes.INTERNAL_ERROR, 'AI生成失败'), 500);
  }
});
