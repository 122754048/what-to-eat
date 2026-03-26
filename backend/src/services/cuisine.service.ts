/**
 * 菜系服务
 * @module services/cuisine.service
 */
import { getCuisinesByFirestore } from '../providers/firebase.provider';

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
  const rows = await getCuisinesByFirestore();
  return rows.map((row: Record<string, unknown>) => ({
    id: row.id as string,
    name: row.name as string,
    nameEn: row.nameEn as string,
    iconUrl: (row.iconUrl as string) ?? '',
    coverImageUrl: (row.coverImageUrl as string) ?? '',
    dishCount: (row.dishCount as number) ?? 0,
    tags: (row.tags as string[]) ?? [],
  }));
}
