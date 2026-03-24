/**
 * 菜系服务
 * @module services/cuisine.service
 */
import { getCuisinesByD1 } from '../providers/database.provider';

export interface Cuisine {
  id: string;
  name: string;
  nameEn: string;
  iconUrl: string;
  coverImageUrl: string;
  dishCount: number;
  tags: string[];
}

/**
 * 获取所有菜系列表
 */
export async function getCuisines(): Promise<Cuisine[]> {
  const stmt = await getCuisinesByD1();
  const result = await stmt.all();
  const rows = (result as { results?: unknown[] }).results ?? [];

  return rows.map((row: unknown) => {
    const r = row as Record<string, unknown>;
    return {
      id: r.id as string,
      name: r.name as string,
      nameEn: r.name_en as string,
      iconUrl: (r.icon_url as string) ?? '',
      coverImageUrl: (r.cover_image_url as string) ?? '',
      dishCount: r.dish_count as number,
      tags: JSON.parse((r.tags as string) ?? '[]'),
    };
  });
}
