/**
 * 菜系服务
 * @module services/cuisine.service
 */
import { getCuisinesByDb } from '../providers/database.provider';

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
  const rows = await getCuisinesByDb();
  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    nameEn: row.name_en,
    iconUrl: row.icon_url ?? '',
    coverImageUrl: row.cover_image_url ?? '',
    dishCount: row.dish_count,
    tags: JSON.parse(row.tags ?? '[]'),
  }));
}
