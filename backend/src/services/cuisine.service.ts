/**
 * 菜系服务
 * @module services/cuisine.service
 */
import { getCuisines as getCuisinesFromDb } from '../providers';

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
  const rows = await getCuisinesFromDb();
  return rows.map((row: Record<string, unknown>) => ({
    id: row.id as string,
    name: row.name as string,
    nameEn: (row.nameEn ?? row.name_en ?? '') as string,
    iconUrl: (row.iconUrl ?? row.icon_url ?? '') as string,
    coverImageUrl: (row.coverImageUrl ?? row.cover_image_url ?? '') as string,
    dishCount: (row.dishCount ?? row.dish_count ?? 0) as number,
    tags: (row.tags as string[]) ?? [],
  }));
}
