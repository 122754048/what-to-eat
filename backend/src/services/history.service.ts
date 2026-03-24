/**
 * 历史记录服务
 * @module services/history.service
 */
import {
  getRecommendationHistory,
  getHistoryCount,
  updateHistoryFeedback,
  getHistoryById,
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
  const [historyStmt, countStmt] = await Promise.all([
    getRecommendationHistory(userId, page, pageSize),
    getHistoryCount(userId),
  ]);

  const [historyResult, countRow] = await Promise.all([
    historyStmt.all(),
    countStmt.first(),
  ]);

  const rows = (historyResult as { results?: unknown[] }).results ?? [];
  const count = countRow as { count: number } | null;

  const items: HistoryItem[] = rows.map((row: unknown) => {
    const r = row as Record<string, unknown>;
    return {
      id: r.id as number,
      dishId: r.dish_id as string,
      dishName: r.dish_name as string,
      cuisineName: r.cuisine_name as string,
      recommendedAt: r.recommended_at as number,
      liked: r.liked as number,
    };
  });

  return {
    items,
    total: count?.count ?? 0,
    page,
    pageSize,
  };
}

/**
 * 反馈推荐结果
 */
export async function giveFeedback(
  historyId: number,
  userId: string,
  liked: number
): Promise<boolean> {
  const stmt = await getHistoryById(historyId);
  const record = await stmt.first() as Record<string, unknown> | null;

  if (!record || record.user_id !== userId) {
    return false;
  }

  await updateHistoryFeedback(historyId, liked);
  return true;
}
