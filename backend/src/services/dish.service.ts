/**
 * 菜品服务
 * @module services/dish.service
 */
import { getDishByIdDb, getCuisineByIdDb } from '../providers/database.provider';

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
  const dish = await getDishByIdDb(dishId);
  if (!dish) return null;

  const cuisine = await getCuisineByIdDb(dish.cuisine_id as string);

  const tags = JSON.parse((dish.tags as string) ?? '[]');
  const recipeData = JSON.parse((dish.recipe as string) ?? '{}');

  return {
    id: dish.id as string,
    name: dish.name as string,
    cuisineId: dish.cuisine_id as string,
    cuisineName: cuisine?.name ?? '',
    imageUrl: (dish.image_url as string) ?? '',
    thumbnailUrl: (dish.thumbnail_url as string) ?? '',
    calories: {
      min: (dish.calories_min as number) ?? 0,
      max: (dish.calories_max as number) ?? 0,
      unit: (dish.calories_unit as string) ?? 'kcal',
    },
    aiRecommendation: (dish.ai_recommendation as string) ?? '',
    tags,
    difficulty: (dish.difficulty as string) ?? '',
    cookTime: (dish.cook_time as string) ?? '',
    recipe: {
      ingredients: recipeData.ingredients ?? [],
      steps: recipeData.steps ?? [],
      tips: recipeData.tips ?? [],
    },
  };
}
