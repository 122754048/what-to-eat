/**
 * 历史记录服务
 * @module services/history.service
 */
import {
  getHistory as getHistoryFromDb,
  getHistoryCount as getHistoryCountFromDb,
  updateFeedback as updateFeedbackDb,
} from '../providers';

export interface HistoryItem {
  id: string;
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
    getHistoryFromDb(userId, page, pageSize),
    getHistoryCountFromDb(userId),
  ]);

  const items: HistoryItem[] = rows.map((row: Record<string, unknown>) => ({
    id: row.id as string,
    dishId: row.dishId as string,
    dishName: (row.dishName ?? row.dish_name ?? '') as string,
    cuisineName: (row.cuisineName ?? row.cuisine_name ?? '') as string,
    recommendedAt: (row.recommendedAt ?? row.recommended_at ?? Date.now()) as number,
    liked: (row.liked ?? 0) as number,
  }));

  return { items, total, page, pageSize };
}

/**
 * 反馈推荐结果
 */
export async function giveFeedback(
  historyId: string,
  userId: string,
  liked: number
): Promise<boolean> {
  // Mock 版本暂不支持用户验证
  await updateFeedbackDb(historyId, liked);
  return true;
}
