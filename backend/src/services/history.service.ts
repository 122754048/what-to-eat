/**
 * 历史记录服务
 * @module services/history.service
 */
import {
  getHistoryDb,
  getHistoryCountDb,
  updateFeedbackDb,
  getHistoryByIdDb,
} from '../providers/database.provider';

export interface HistoryItem {
  id: number;
  dishId: string;
  dishName: string;
  cuisineName: string;
  recommendedAt: number;
  liked: number;
}

export interface HistoryResult {
  items: HistoryItem[];
  total: number;
  page: number;
  pageSize: number;
}

/**
 * 获取推荐历史
 */
export async function getHistory(
  userId: string,
  page: number,
  pageSize: number
): Promise<HistoryResult> {
  const [rows, total] = await Promise.all([
    getHistoryDb(userId, page, pageSize),
    getHistoryCountDb(userId),
  ]);

  const items: HistoryItem[] = rows.map((row) => ({
    id: row.id,
    dishId: row.dish_id,
    dishName: row.dish_name,
    cuisineName: row.cuisine_name,
    recommendedAt: row.recommended_at,
    liked: row.liked,
  }));

  return { items, total, page, pageSize };
}

/**
 * 反馈推荐结果
 */
export async function giveFeedback(
  historyId: number,
  userId: string,
  liked: number
): Promise<boolean> {
  const record = await getHistoryByIdDb(historyId);
  if (!record || record.user_id !== userId) return false;
  await updateFeedbackDb(historyId, liked);
  return true;
}
