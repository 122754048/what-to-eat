/**
 * 推荐服务
 * @module services/recommend.service
 */
import {
  getRandomDishByCuisine,
  getCuisineById,
  insertHistory,
  getExcludedDishes,
  addExcludedDish,
} from '../providers';

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
  const cuisine = await getCuisineById(cuisineId);
  if (!cuisine) return null;

  let excludeIds: string[] = [];
  if (excludePrevious) {
    excludeIds = await getExcludedDishes(userId);
  }

  const dish = await getRandomDishByCuisine(cuisineId, excludeIds);
  if (!dish) return null;

  const aiRecommendation =
    FALLBACK_RECOMMENDATIONS[
      Math.floor(Math.random() * FALLBACK_RECOMMENDATIONS.length)
    ];

  await addExcludedDish(userId, dish.id);
  await insertHistory(userId, dish.id, cuisineId);

  const d = dish as Record<string, unknown>;
  return {
    id: d.id as string,
    name: d.name as string,
    cuisineId: d.cuisineId as string,
    cuisineName: cuisine.name as string,
    imageUrl: (d.imageUrl as string) ?? '',
    thumbnailUrl: (d.thumbnailUrl as string) ?? '',
    calories: {
      min: (d.caloriesMin as number) ?? 0,
      max: (d.caloriesMax as number) ?? 0,
      unit: (d.caloriesUnit as string) ?? 'kcal',
    },
    aiRecommendation,
    tags: (d.tags as string[]) ?? [],
    difficulty: (d.difficulty as string) ?? '',
    cookTime: (d.cookTime as string) ?? '',
  };
}
