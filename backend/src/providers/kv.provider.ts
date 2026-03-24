/**
 * KV Provider（会话级去重）
 * @module providers/kv.provider
 */
import type { KVNamespace } from '@cloudflare/workers-types';

declare const KV: KVNamespace;

const SESSION_EXCLUDED_DISHES_PREFIX = 'session:excluded_dishes:';
const SESSION_TTL = 60 * 60 * 24; // 24小时

/**
 * 获取用户会话中已推荐的菜品ID列表
 */
export async function getExcludedDishes(userId: string): Promise<string[]> {
  const key = `${SESSION_EXCLUDED_DISHES_PREFIX}${userId}`;
  const value = await KV.get(key, 'text');
  if (!value) return [];
  try {
    return JSON.parse(value);
  } catch {
    return [];
  }
}

/**
 * 添加一道菜品到会话排除列表
 */
export async function addExcludedDish(userId: string, dishId: string): Promise<void> {
  const key = `${SESSION_EXCLUDED_DISHES_PREFIX}${userId}`;
  const existing = await getExcludedDishes(userId);
  if (!existing.includes(dishId)) {
    existing.push(dishId);
    await KV.put(key, JSON.stringify(existing), { expirationTtl: SESSION_TTL });
  }
}

/**
 * 清除用户会话排除列表
 */
export async function clearExcludedDishes(userId: string): Promise<void> {
  const key = `${SESSION_EXCLUDED_DISHES_PREFIX}${userId}`;
  await KV.delete(key);
}
