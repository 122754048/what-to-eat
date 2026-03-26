/**
 * 历史记录服务
 * @module services/history.service
 */
import {
  getHistoryFirestore,
  getHistoryCountFirestore,
  updateFeedbackFirestore,
  getHistoryByIdFirestore,
} from '../providers/firebase.provider';

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
  const [items, total] = await Promise.all([
    getHistoryFirestore(userId, page, pageSize),
    getHistoryCountFirestore(userId),
  ]);

  return {
    items: items.map((row: Record<string, unknown>) => ({
      id: row.id as string,
      dishId: row.dishId as string,
      dishName: row.dishName as string,
      cuisineName: row.cuisineName as string,
      recommendedAt: row.recommendedAt as number,
      liked: (row.liked as number) ?? 0,
    })),
    total,
    page,
    pageSize,
  };
}

/**
 * 反馈推荐结果
 */
export async function giveFeedback(
  historyId: string,
  userId: string,
  liked: number
): Promise<boolean> {
  const record = await getHistoryByIdFirestore(historyId);
  if (!record || (record as Record<string, unknown>).userId !== userId) return false;
  await updateFeedbackFirestore(historyId, liked);
  return true;
}
