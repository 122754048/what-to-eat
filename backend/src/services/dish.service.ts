/**
 * 菜品服务
 * @module services/dish.service
 */
import {
  getDishByIdFirestore,
  getCuisineByIdFirestore,
} from '../providers/firebase.provider';

export interface DishDetail {
  id: string;
  name: string;
  cuisineId: string;
  cuisineName: string;
  imageUrl: string;
  thumbnailUrl: string;
  calories: { min: number; max: number; unit: string };
  aiRecommendation: string;
  tags: string[];
  difficulty: string;
  cookTime: string;
  recipe: {
    ingredients: Array<{ name: string; amount: string }>;
    steps: string[];
    tips: string[];
  };
}

/**
 * 获取菜品详情
 */
export async function getDishDetail(dishId: string): Promise<DishDetail | null> {
  const dish = await getDishByIdFirestore(dishId);
  if (!dish) return null;

  const d = dish as Record<string, unknown>;
  const cuisineId = d.cuisineId as string;
  const cuisine = cuisineId ? await getCuisineByIdFirestore(cuisineId) : null;

  return {
    id: d.id as string,
    name: d.name as string,
    cuisineId,
    cuisineName: cuisine?.name as string ?? '',
    imageUrl: (d.imageUrl as string) ?? '',
    thumbnailUrl: (d.thumbnailUrl as string) ?? '',
    calories: {
      min: (d.caloriesMin as number) ?? 0,
      max: (d.caloriesMax as number) ?? 0,
      unit: (d.caloriesUnit as string) ?? 'kcal',
    },
    aiRecommendation: (d.aiRecommendation as string) ?? '',
    tags: (d.tags as string[]) ?? [],
    difficulty: (d.difficulty as string) ?? '',
    cookTime: (d.cookTime as string) ?? '',
    recipe: {
      ingredients: [],
      steps: [],
      tips: [],
    },
  };
}
