/**
 * 数据库 Provider（D1）
 * @module providers/database.provider
 */
import type { D1Database } from '@cloudflare/workers-types';

declare const DB: D1Database;

/**
 * 获取菜系列表
 */
export async function getCuisinesByD1() {
  return DB.prepare('SELECT * FROM cuisines ORDER BY dish_count DESC');
}

/**
 * 根据ID获取菜系
 */
export async function getCuisineById(id: string) {
  return DB.prepare('SELECT * FROM cuisines WHERE id = ?').bind(id);
}

/**
 * 随机获取菜品（排除指定ID）
 */
export async function getRandomDishByCuisine(cuisineId: string, excludeIds: string[] = []) {
  let sql = 'SELECT * FROM dishes WHERE cuisine_id = ?';
  const bindings: (string | number)[] = [cuisineId];

  if (excludeIds.length > 0) {
    const placeholders = excludeIds.map(() => '?').join(',');
    sql += ` AND id NOT IN (${placeholders})`;
    bindings.push(...excludeIds);
  }

  sql += ' ORDER BY RANDOM() LIMIT 1';
  return DB.prepare(sql).bind(...bindings);
}

/**
 * 根据ID获取菜品
 */
export async function getDishById(id: string) {
  return DB.prepare('SELECT * FROM dishes WHERE id = ?').bind(id);
}

/**
 * 记录推荐历史
 */
export async function insertRecommendationHistory(userId: string, dishId: string, cuisineId: string) {
  return DB.prepare(
    'INSERT INTO recommendation_history (user_id, dish_id, cuisine_id) VALUES (?, ?, ?)'
  ).bind(userId, dishId, cuisineId);
}

/**
 * 获取用户推荐历史
 */
export async function getRecommendationHistory(userId: string, page: number, pageSize: number) {
  const offset = (page - 1) * pageSize;
  return DB.prepare(`
    SELECT rh.*, d.name as dish_name, c.name as cuisine_name
    FROM recommendation_history rh
    JOIN dishes d ON rh.dish_id = d.id
    JOIN cuisines c ON rh.cuisine_id = c.id
    WHERE rh.user_id = ?
    ORDER BY rh.recommended_at DESC
    LIMIT ? OFFSET ?
  `).bind(userId, pageSize, offset);
}

/**
 * 获取历史记录总数
 */
export async function getHistoryCount(userId: string) {
  return DB.prepare(
    'SELECT COUNT(*) as count FROM recommendation_history WHERE user_id = ?'
  ).bind(userId);
}

/**
 * 更新反馈
 */
export async function updateHistoryFeedback(historyId: number, liked: number) {
  return DB.prepare(
    'UPDATE recommendation_history SET liked = ? WHERE id = ?'
  ).bind(liked, historyId);
}

/**
 * 获取历史记录by ID
 */
export async function getHistoryById(historyId: number) {
  return DB.prepare('SELECT * FROM recommendation_history WHERE id = ?').bind(historyId);
}
