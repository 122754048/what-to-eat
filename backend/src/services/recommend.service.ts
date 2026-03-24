/**
 * 推荐服务
 * @module services/recommend.service
 */
import type { D1Database, KVNamespace } from '@cloudflare/workers-types';
import { getRandomDishByCuisine, getCuisineById, insertRecommendationHistory } from '../providers/database.provider';
import { generateAIRecommendation } from '../providers/ai.provider';
import { getExcludedDishes, addExcludedDish } from '../providers/kv.provider';

// D1/KV 通过 wrangler.toml 绑定，运行时注入
declare const DB: D1Database;
declare const KV: KVNamespace;

export interface Dish {
  id: string;
  name: string;
  cuisineId: string;
  cuisineName: string;
  imageUrl: string;
  thumbnailUrl: string;
  calories: {
    min: number;
    max: number;
    unit: string;
  };
  aiRecommendation: string;
  tags: string[];
  difficulty: string;
  cookTime: string;
}

/**
 * 随机推荐一道菜品
 */
export async function recommendDish(
  cuisineId: string,
  userId: string,
  excludePrevious: boolean
): Promise<Dish | null> {
  // 检查菜系是否存在
  const cuisineStmt = await getCuisineById(cuisineId);
  const cuisine = await cuisineStmt.first();
  if (!cuisine) return null;

  // 获取需要排除的菜品ID
  let excludeIds: string[] = [];
  if (excludePrevious) {
    excludeIds = await getExcludedDishes(userId);
  }

  // 随机查询一道菜品
  const dishStmt = await getRandomDishByCuisine(cuisineId, excludeIds);
  const dish = await dishStmt.first() as Record<string, unknown> | null;
  if (!dish) return null;

  // 生成AI推荐理由
  const aiRecommendation = await generateAIRecommendation(dish.name as string);

  // 记录到KV（会话级去重）
  await addExcludedDish(userId, dish.id as string);

  // 记录到历史
  await insertRecommendationHistory(userId, dish.id as string, cuisineId);

  return formatDish(dish, cuisine, aiRecommendation);
}

function formatDish(
  dish: Record<string, unknown>,
  cuisine: Record<string, unknown>,
  aiRecommendation: string
): Dish {
  const tags = JSON.parse((dish.tags as string) ?? '[]');
  const recipe = JSON.parse((dish.recipe as string) ?? '{}');

  return {
    id: dish.id as string,
    name: dish.name as string,
    cuisineId: dish.cuisine_id as string,
    cuisineName: cuisine.name as string,
    imageUrl: (dish.image_url as string) ?? '',
    thumbnailUrl: (dish.thumbnail_url as string) ?? '',
    calories: {
      min: (dish.calories_min as number) ?? 0,
      max: (dish.calories_max as number) ?? 0,
      unit: (dish.calories_unit as string) ?? 'kcal',
    },
    aiRecommendation,
    tags,
    difficulty: (dish.difficulty as string) ?? '',
    cookTime: (dish.cook_time as string) ?? '',
  };
}
