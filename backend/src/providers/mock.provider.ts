/**
 * Mock Data Provider
 * 当 Firebase 未配置时，返回本地 Mock 数据用于开发和联调
 */

const MOCK_CUISINES = [
  { id: 'chinese_sichuan', name: '川菜', nameEn: 'Sichuan', iconUrl: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=800', tags: ['辣', '麻辣', '经典'], dishCount: 28 },
  { id: 'chinese_cantonese', name: '粤菜', nameEn: 'Cantonese', iconUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800', tags: ['清淡', '鲜嫩', '养生'], dishCount: 24 },
  { id: 'chinese_hunan', name: '湘菜', nameEn: 'Hunan', iconUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800', tags: ['辣', '酸辣', '开胃'], dishCount: 20 },
  { id: 'chinese_shandong', name: '鲁菜', nameEn: 'Shandong', iconUrl: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800', tags: ['鲜香', '咸鲜', '清淡'], dishCount: 18 },
  { id: 'chinese_jiangsu', name: '苏菜', nameEn: 'Jiangsu', iconUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: ['清淡', '甜', '精致'], dishCount: 22 },
  { id: 'chinese_zhejiang', name: '浙菜', nameEn: 'Zhejiang', iconUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: ['清淡', '鲜香', '细腻'], dishCount: 19 },
  { id: 'chinese_fujian', name: '闽菜', nameEn: 'Fujian', iconUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: ['鲜香', '清淡', '滋补'], dishCount: 16 },
  { id: 'chinese_anhui', name: '徽菜', nameEn: 'Anhui', iconUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: ['鲜香', '浓郁', '原汁原味'], dishCount: 15 },
];

const MOCK_DISHES = [
  { id: 'dish_kungpao_chicken', cuisineId: 'chinese_sichuan', name: '宫保鸡丁', imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=200', caloriesMin: 250, caloriesMax: 350, caloriesUnit: 'kcal', tags: ['经典', '下饭', '微辣'], difficulty: '简单', cookTime: '25分钟', aiRecommendation: '经典川菜代表，花生与鸡丁的完美碰撞！' },
  { id: 'dish_mapo_tofu', cuisineId: 'chinese_sichuan', name: '麻婆豆腐', imageUrl: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=200', caloriesMin: 180, caloriesMax: 280, caloriesUnit: 'kcal', tags: ['经典', '麻辣', '下饭'], difficulty: '简单', cookTime: '20分钟', aiRecommendation: '川菜经典，豆腐嫩滑，麻辣鲜香！' },
  { id: 'dish_white_boiled_fish', cuisineId: 'chinese_cantonese', name: '清蒸鱼', imageUrl: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=200', caloriesMin: 150, caloriesMax: 220, caloriesUnit: 'kcal', tags: ['清淡', '养生', '鲜嫩'], difficulty: '中等', cookTime: '30分钟', aiRecommendation: '粤菜精髓，原汁原味，鱼肉嫩滑！' },
  { id: 'dish_char_siu', cuisineId: 'chinese_cantonese', name: '叉烧肉', imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200', caloriesMin: 280, caloriesMax: 380, caloriesUnit: 'kcal', tags: ['经典', '甜香', '色泽红润'], difficulty: '中等', cookTime: '40分钟', aiRecommendation: '港式经典，外焦里嫩，甜咸交织！' },
  { id: 'dish_chairman_mao_pork', cuisineId: 'chinese_hunan', name: '毛氏红烧肉', imageUrl: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=200', caloriesMin: 350, caloriesMax: 450, caloriesUnit: 'kcal', tags: ['经典', '色泽红亮', '软糯'], difficulty: '中等', cookTime: '60分钟', aiRecommendation: '湘菜之王，色泽红亮，入口即化！' },
  { id: 'dish_spicy_crayfish', cuisineId: 'chinese_hunan', name: '口味虾', imageUrl: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=200', caloriesMin: 200, caloriesMax: 300, caloriesUnit: 'kcal', tags: ['辣', '夜宵', '过瘾'], difficulty: '中等', cookTime: '35分钟', aiRecommendation: '湘味十足，辣到飞起又停不下来！' },
  { id: 'dish_degu_braised_prawns', cuisineId: 'chinese_shandong', name: '德州扒鸡', imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=200', caloriesMin: 280, caloriesMax: 380, caloriesUnit: 'kcal', tags: ['经典', '香嫩', '脱骨'], difficulty: '较难', cookTime: '90分钟', aiRecommendation: '鲁菜名吃，肉质软烂，轻轻一抖就脱骨！' },
  { id: 'dish_braised_sea_cucumber', cuisineId: 'chinese_shandong', name: '葱烧海参', imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=200', caloriesMin: 150, caloriesMax: 250, caloriesUnit: 'kcal', tags: ['高端', '滋补', '鲜美'], difficulty: '较难', cookTime: '45分钟', aiRecommendation: '鲁菜经典，海参软糯，葱香四溢！' },
  { id: 'dish_squirrel_fish', cuisineId: 'chinese_jiangsu', name: '松鼠桂鱼', imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200', caloriesMin: 220, caloriesMax: 320, caloriesUnit: 'kcal', tags: ['经典', '酸甜', '造型独特'], difficulty: '较难', cookTime: '50分钟', aiRecommendation: '苏菜代表作，外酥里嫩，酸甜可口！' },
  { id: 'dish_yangzhou_fried_rice', cuisineId: 'chinese_jiangsu', name: '扬州炒饭', imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=200', caloriesMin: 300, caloriesMax: 400, caloriesUnit: 'kcal', tags: ['经典', '主食', '丰盛'], difficulty: '简单', cookTime: '20分钟', aiRecommendation: '米饭粒粒分明，配料丰富，一碗也是盛宴！' },
];

// 历史记录（内存存储）
const MOCK_HISTORY: Record<string, Array<{ id: string; dishId: string; cuisineId: string; recommendedAt: number; liked: number }>> = {};

// 会话排除（内存存储）
const SESSION_EXCLUSION: Record<string, { dishIds: string[]; expiresAt: number }> = {};

export const MOCK_HISTORY_COLLECTION = 'recommendationHistory';

// ============ 菜系操作（Mock）============

export function getCuisinesByMock() {
  return MOCK_CUISINES;
}

export function getCuisineByIdMock(id: string) {
  return MOCK_CUISINES.find(c => c.id === id) ?? null;
}

// ============ 菜品操作（Mock）============

export function getDishesByMock() {
  return MOCK_DISHES;
}

export function getDishByIdMock(id: string) {
  return MOCK_DISHES.find(d => d.id === id) ?? null;
}

export function getRandomDishByCuisineMock(cuisineId: string, excludeIds: string[] = []) {
  const filtered = MOCK_DISHES.filter(d => d.cuisineId === cuisineId && !excludeIds.includes(d.id));
  if (filtered.length === 0) return null;
  const dish = filtered[Math.floor(Math.random() * filtered.length)];
  // dish 已有 id 字段，直接返回
  return dish;
}

// ============ 历史记录操作（Mock）============

export function insertHistoryMock(userId: string, dishId: string, cuisineId: string) {
  if (!MOCK_HISTORY[userId]) MOCK_HISTORY[userId] = [];
  const id = `mock_hist_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
  MOCK_HISTORY[userId].unshift({ id, dishId, cuisineId, recommendedAt: Date.now(), liked: 0 });
  return id;
}

export function getHistoryMock(userId: string, page: number, pageSize: number) {
  const list = MOCK_HISTORY[userId] ?? [];
  const offset = (page - 1) * pageSize;
  return list.slice(offset, offset + pageSize).map(h => {
    const dish = MOCK_DISHES.find(d => d.id === h.dishId) ?? { name: '未知菜品', cuisineId: '' };
    const cuisine = MOCK_CUISINES.find(c => c.id === h.cuisineId) ?? { name: '未知菜系' };
    return { ...h, dishName: dish.name, cuisineName: cuisine.name };
  });
}

export function getHistoryCountMock(userId: string) {
  return MOCK_HISTORY[userId]?.length ?? 0;
}

export function updateFeedbackMock(historyId: string, liked: number) {
  for (const userId in MOCK_HISTORY) {
    const hist = MOCK_HISTORY[userId].find(h => h.id === historyId);
    if (hist) { hist.liked = liked; return; }
  }
}

// ============ 会话去重（Mock）============

export function getExcludedDishesMock(userId: string): string[] {
  const entry = SESSION_EXCLUSION[userId];
  if (!entry) return [];
  if (Date.now() > entry.expiresAt) { delete SESSION_EXCLUSION[userId]; return []; }
  return entry.dishIds;
}

export function addExcludedDishMock(userId: string, dishId: string): void {
  const SESSION_TTL_MS = 24 * 60 * 60 * 1000;
  if (!SESSION_EXCLUSION[userId]) SESSION_EXCLUSION[userId] = { dishIds: [], expiresAt: 0 };
  const entry = SESSION_EXCLUSION[userId];
  if (Date.now() > entry.expiresAt) { entry.dishIds = []; entry.expiresAt = 0; }
  if (!entry.dishIds.includes(dishId)) entry.dishIds.push(dishId);
  entry.expiresAt = Date.now() + SESSION_TTL_MS;
}
