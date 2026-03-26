/**
 * 菜品服务
 * @module services/dish.service
 */
import {
  getDishById as getDishByIdFromDb,
  getCuisineById as getCuisineByIdFromDb,
} from '../providers';

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
  const dish = await getDishByIdFromDb(dishId);
  if (!dish) return null;

  const d = dish as Record<string, unknown>;
  const cuisineId = d.cuisineId as string;
  const cuisine = cuisineId ? await getCuisineByIdFromDb(cuisineId) : null;

  return {
    id: d.id as string,
    name: d.name as string,
    cuisineId,
    cuisineName: (cuisine?.name ?? '') as string,
    imageUrl: (d.imageUrl ?? d.image_url ?? '') as string,
    thumbnailUrl: (d.thumbnailUrl ?? d.thumbnail_url ?? '') as string,
    calories: {
      min: (d.caloriesMin ?? d.calories_min ?? 0) as number,
      max: (d.caloriesMax ?? d.calories_max ?? 0) as number,
      unit: (d.caloriesUnit ?? d.calories_unit ?? 'kcal') as string,
    },
    aiRecommendation: (d.aiRecommendation ?? d.ai_recommendation ?? '') as string,
    tags: (d.tags as string[]) ?? [],
    difficulty: (d.difficulty ?? '') as string,
    cookTime: (d.cookTime ?? d.cook_time ?? '') as string,
    recipe: {
      ingredients: [],
      steps: [],
      tips: [],
    },
  };
}
