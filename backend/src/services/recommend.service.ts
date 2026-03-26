/**
 * 推荐服务
 * @module services/recommend.service
 */
import {
  getRandomDishByCuisineDb,
  getCuisineByIdDb,
  insertHistory,
  getExcludedDishesDb,
  addExcludedDishDb,
} from '../providers/database.provider';

export interface Dish {
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
}

const FALLBACK_RECOMMENDATIONS = [
  '经典菜品，口碑极佳，值得一试！',
  '这道菜深受大家喜爱，快来尝尝吧！',
  '香气扑鼻，保证让你胃口大开！',
  '色香味俱全，绝对是下饭神器！',
  '厨房小白也能轻松搞定，快来试试！',
];

/**
 * 随机推荐一道菜品
 */
export async function recommendDish(
  cuisineId: string,
  userId: string,
  excludePrevious: boolean
): Promise<Dish | null> {
  // 检查菜系是否存在
  const cuisine = await getCuisineByIdDb(cuisineId);
  if (!cuisine) return null;

  // 获取需要排除的菜品ID
  let excludeIds: string[] = [];
  if (excludePrevious) {
    excludeIds = await getExcludedDishesDb(userId);
  }

  // 随机查询一道菜品
  const dish = await getRandomDishByCuisineDb(cuisineId, excludeIds);
  if (!dish) return null;

  // 预置推荐理由
  const aiRecommendation =
    FALLBACK_RECOMMENDATIONS[
      Math.floor(Math.random() * FALLBACK_RECOMMENDATIONS.length)
    ];

  // 更新会话排除列表
  await addExcludedDishDb(userId, dish.id);

  // 记录到历史
  await insertHistory(userId, dish.id, cuisineId);

  return formatDish(dish, cuisine.name, aiRecommendation);
}

function formatDish(
  dish: Record<string, unknown>,
  cuisineName: string,
  aiRecommendation: string
): Dish {
  return {
    id: dish.id as string,
    name: dish.name as string,
    cuisineId: dish.cuisine_id as string,
    cuisineName,
    imageUrl: (dish.image_url as string) ?? '',
    thumbnailUrl: (dish.thumbnail_url as string) ?? '',
    calories: {
      min: (dish.calories_min as number) ?? 0,
      max: (dish.calories_max as number) ?? 0,
      unit: (dish.calories_unit as string) ?? 'kcal',
    },
    aiRecommendation,
    tags: JSON.parse((dish.tags as string) ?? '[]'),
    difficulty: (dish.difficulty as string) ?? '',
    cookTime: (dish.cook_time as string) ?? '',
  };
}
