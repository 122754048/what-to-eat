/**
 * AI菜品生成服务
 * @module services/ai-dish.service
 *
 * V2.0 Phase 1：Mock优先，支持 mealContext + allergies
 * 响应格式：{ name, reason, calories, pairings, imageUrl }
 */
export interface GenerateDishInput {
  cuisineId: string;
  mealContext?: string;      // 餐食场景：早餐/午餐/晚餐/夜宵
  allergies?: string[];      // 过敏原：虾/花生/乳制品等
}

export interface DishPairings {
  dishes: string[];   // 配菜
  drinks: string[];   // 饮品
}

export interface GeneratedDish {
  name: string;
  reason: string;          // AI推荐理由
  calories: string;       // 格式 "300-400"
  pairings: DishPairings;  // 搭配推荐
  imageUrl: string;
  allergies?: string[];    // 常见过敏原（内部使用）
  dietaryNote?: string;   // 饮食说明（内部使用）
}

// 菜系名称映射
const CUISINE_NAMES: Record<string, string> = {
  chinese_sichuan: '川菜',
  chinese_cantonese: '粤菜',
  chinese_hunan: '湘菜',
  chinese_shandong: '鲁菜',
  chinese_jiangsu: '苏菜',
  chinese_zhejiang: '浙菜',
  chinese_fujian: '闽菜',
  chinese_anhui: '徽菜',
  japanese: '日料',
  korean: '韩餐',
  italian: '意大利菜',
  french: '法国菜',
  american: '美式餐',
  thai: '泰国菜',
  indian: '印度菜',
  mexican: '墨西哥菜',
  healthy: '健康餐',
  default: '创意菜',
};

// 饮品库
const DRINKS: Record<string, string[]> = {
  辣: ['柠檬茶', '酸梅汤', '凉茶', '冰可乐'],
  麻辣: ['酸梅汤', '柠檬茶', '椰汁'],
  酸辣: ['酸梅汤', '柠檬水', '蜂蜜水'],
  清淡: ['柠檬水', '菊花茶', '绿茶', '椰汁'],
  甜: ['柠檬水', '绿茶', '茉莉花茶'],
  鲜: ['柠檬水', '菊花茶', '苏打水'],
  养生: ['枸杞茶', '红枣茶', '绿茶', '山楂茶'],
  default: ['柠檬水', '绿茶', '苏打水'],
};

// 配菜库（按场景）
const PAIRING_DISHES: Record<string, string[]> = {
  早餐: ['白粥', '豆浆', '油条', '小笼包'],
  午餐: ['米饭', '馒头', '面条'],
  晚餐: ['米饭', '粥', '杂粮饭'],
  夜宵: ['啤酒', '饮料', '小吃'],
  default: ['米饭', '粥', '面条'],
};

// Mock菜品库
const MOCK_DISHES: Record<string, GeneratedDish[]> = {
  chinese_sichuan: [
    {
      name: '水煮牛肉',
      reason: '麻辣鲜香，牛肉嫩滑，热油激香，保证让你胃口大开！',
      calories: '300-400',
      pairings: { dishes: ['米饭'], drinks: ['酸梅汤', '柠檬茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=800',
    },
    {
      name: '酸菜鱼',
      reason: '酸辣开胃，鱼肉鲜嫩，汤汁浓郁，吃一口就爱上！',
      calories: '200-300',
      pairings: { dishes: ['米饭'], drinks: ['酸梅汤', '凉茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800',
    },
    {
      name: '干煸四季豆',
      reason: '干香入味，四季豆脆嫩，下饭神器！',
      calories: '150-200',
      pairings: { dishes: ['米饭'], drinks: ['柠檬茶', '绿茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1584278860047-22db9ff82ef6?w=800',
      allergies: ['虾'], // 四季豆本身无常见过敏原
    },
    {
      name: '回锅肉',
      reason: '肥而不腻，色泽红亮，蒜香浓郁，川菜经典！',
      calories: '350-450',
      pairings: { dishes: ['米饭', '馒头'], drinks: ['酸梅汤', '绿茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
    },
    {
      name: '宫保鸡丁',
      reason: '糊辣荔枝口，花生酥脆，鸡丁嫩滑，经典中的经典！',
      calories: '250-350',
      pairings: { dishes: ['米饭'], drinks: ['柠檬茶', '酸梅汤'] },
      imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800',
      allergies: ['花生'],
    },
    {
      name: '麻婆豆腐',
      reason: '川菜经典，豆腐嫩滑，麻辣鲜香，下饭神器！',
      calories: '180-280',
      pairings: { dishes: ['米饭'], drinks: ['酸梅汤', '豆浆'] },
      imageUrl: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=800',
      allergies: ['大豆'],
    },
    {
      name: '鱼香肉丝',
      reason: '酸甜咸辣鲜五味俱全，开胃下饭，口感丰富！',
      calories: '280-380',
      pairings: { dishes: ['米饭'], drinks: ['柠檬茶', '酸梅汤'] },
      imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800',
    },
    {
      name: '辣子鸡',
      reason: '干辣椒段炸至香脆，鸡肉外酥里嫩，辣得过瘾！',
      calories: '300-400',
      pairings: { dishes: ['米饭'], drinks: ['酸梅汤', '冰可乐'] },
      imageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800',
    },
  ],
  chinese_cantonese: [
    {
      name: '白切鸡',
      reason: '皮爽肉滑，原汁原味，姜葱酱料绝配，粤菜灵魂！',
      calories: '200-280',
      pairings: { dishes: ['米饭', '白粥'], drinks: ['枸杞茶', '椰汁'] },
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800',
    },
    {
      name: '清蒸石斑',
      reason: '鱼肉鲜嫩，清淡少油，保留海鲜原味，养生首选！',
      calories: '120-180',
      pairings: { dishes: ['米饭'], drinks: ['柠檬水', '菊花茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=800',
      allergies: ['鱼'],
    },
    {
      name: '叉烧肉',
      reason: '外焦里嫩，甜香四溢，港式经典，一口就爱上！',
      calories: '280-380',
      pairings: { dishes: ['米饭', '面条'], drinks: ['柠檬茶', '奶茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
      allergies: ['大豆'],
    },
    {
      name: '上汤娃娃菜',
      reason: '汤鲜菜嫩，清淡爽口，老少皆宜，健康之选！',
      calories: '80-120',
      pairings: { dishes: ['米饭', '粥'], drinks: ['菊花茶', '柠檬水'] },
      imageUrl: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800',
      dietaryNote: '低脂低热量，适合减脂人群',
    },
    {
      name: '煲仔饭',
      reason: '米饭香糯，锅巴酥脆，腊味十足，一锅满足！',
      calories: '400-500',
      pairings: { dishes: [], drinks: ['柠檬茶', '咸柠七'] },
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
    },
  ],
  chinese_hunan: [
    {
      name: '剁椒鱼头',
      reason: '剁椒铺满鱼头，鲜辣过瘾，汤汁拌面一绝！',
      calories: '200-300',
      pairings: { dishes: ['面条', '米饭'], drinks: ['酸梅汤', '凉茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800',
      allergies: ['鱼'],
    },
    {
      name: '小炒黄牛肉',
      reason: '猛火爆炒，牛肉嫩滑，泡椒提味，下饭神器！',
      calories: '200-280',
      pairings: { dishes: ['米饭'], drinks: ['酸梅汤', '冰可乐'] },
      imageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800',
      allergies: ['鱼'],
    },
    {
      name: '毛氏红烧肉',
      reason: '色泽红亮，肥而不腻，入口即化，湘菜之王！',
      calories: '400-500',
      pairings: { dishes: ['米饭', '馒头'], drinks: ['酸梅汤', '绿茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=800',
    },
    {
      name: '腊味合蒸',
      reason: '腊肉腊肠同蒸，香味交融，下饭绝佳！',
      calories: '300-400',
      pairings: { dishes: ['米饭'], drinks: ['绿茶', '咸柠七'] },
      imageUrl: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=800',
    },
  ],
  healthy: [
    {
      name: '藜麦鸡胸沙拉',
      reason: '高蛋白低脂肪，藜麦饱腹，鸡胸肉嫩滑，减脂必备！',
      calories: '350-450',
      pairings: { dishes: [], drinks: ['柠檬水', '黑咖啡'] },
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      allergies: ['鸡蛋'],
    },
    {
      name: '西兰花虾仁',
      reason: '清炒少油，虾仁Q弹，西兰花脆嫩，低脂高蛋白！',
      calories: '150-200',
      pairings: { dishes: ['糙米'], drinks: ['柠檬水', '苏打水'] },
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
      allergies: ['虾'],
    },
    {
      name: '三文鱼牛油果碗',
      reason: 'Omega-3丰富，三文鱼嫩滑，牛油果绵密，网红健康餐！',
      calories: '450-550',
      pairings: { dishes: [], drinks: ['柠檬水', '椰子水'] },
      imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800',
      allergies: ['鱼'],
    },
    {
      name: '番茄龙利鱼',
      reason: '酸甜开胃，龙利鱼无骨无刺，嫩滑可口，老少皆宜！',
      calories: '180-250',
      pairings: { dishes: ['糙米'], drinks: ['柠檬水', '菊花茶'] },
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800',
      allergies: ['鱼'],
    },
    {
      name: '鸡胸肉蔬菜卷',
      reason: '高蛋白低卡，蔬菜丰富，一张饼搞定一餐！',
      calories: '300-380',
      pairings: { dishes: [], drinks: ['黑咖啡', '柠檬水'] },
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800',
      allergies: ['鸡蛋', '小麦'],
    },
  ],
};

// 默认菜品
const DEFAULT_DISHES: GeneratedDish[] = [
  {
    name: '香煎鸡胸肉配蔬菜',
    reason: '外焦里嫩，营养均衡，健康美味，健身首选！',
    calories: '300-380',
    pairings: { dishes: ['糙米', '藜麦'], drinks: ['柠檬水', '黑咖啡'] },
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
    allergies: ['鸡蛋'],
  },
  {
    name: '蒜蓉蒸虾',
    reason: '蒜香浓郁，虾肉鲜甜，蒸制更健康，老少皆宜！',
    calories: '150-220',
    pairings: { dishes: ['米饭'], drinks: ['柠檬水', '菊花茶'] },
    imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800',
    allergies: ['虾'],
  },
];

/**
 * 过敏原过滤
 * 如果用户的过敏原与菜品过敏原冲突，返回 null
 */
function filterByAllergies(dish: GeneratedDish, allergies: string[]): GeneratedDish | null {
  if (!allergies || allergies.length === 0) return dish;

  const dishAllergens = dish.allergies ?? [];
  for (const allergy of allergies) {
    for (const allergen of dishAllergens) {
      if (allergy.includes(allergen) || allergen.includes(allergy)) {
        return null;
      }
    }
  }
  return dish;
}

/**
 * 过滤后的随机选择
 */
function selectFilteredDish(dishes: GeneratedDish[], allergies: string[]): GeneratedDish {
  const filtered = dishes.filter(d => filterByAllergies(d, allergies));

  if (filtered.length > 0) {
    return filtered[Math.floor(Math.random() * filtered.length)];
  }

  // 没有找到无过敏的，返回热量最低的
  return [...dishes].sort((a, b) => {
    const aMax = parseInt(a.calories.split('-')[1]);
    const bMax = parseInt(b.calories.split('-')[1]);
    return aMax - bMax;
  })[0];
}

/**
 * 根据餐食场景调整配菜
 */
function adjustPairingsByContext(pairings: DishPairings, mealContext?: string): DishPairings {
  if (!mealContext) return pairings;

  const contextDishes = PAIRING_DISHES[mealContext] ?? PAIRING_DISHES.default;

  return {
    dishes: pairings.dishes.length > 0 ? pairings.dishes : contextDishes.slice(0, 1),
    drinks: pairings.drinks,
  };
}

/**
 * 根据心情/场景微调选择
 */
function selectByMood(dishes: GeneratedDish[], mood?: string): GeneratedDish[] {
  if (!mood) return dishes;

  if (mood.includes('辣') || mood.includes('重口') || mood.includes('刺激')) {
    return dishes.filter(d => d.reason.includes('辣') || d.reason.includes('麻辣'));
  }

  if (mood.includes('清淡') || mood.includes('健康') || mood.includes('养生')) {
    return dishes.filter(d => d.reason.includes('清淡') || d.reason.includes('养生') || d.reason.includes('健康'));
  }

  if (mood.includes('快') || mood.includes('简单') || mood.includes('懒')) {
    return dishes.filter(d => parseInt(d.calories.split('-')[0]) < 250);
  }

  if (mood.includes('饱') || mood.includes('多') || mood.includes('丰盛')) {
    return dishes.filter(d => parseInt(d.calories.split('-')[1]) > 350);
  }

  return dishes;
}

/**
 * 生成AI菜品
 * V2.0 Phase 1：Mock数据，支持 mealContext + allergies
 */
export async function generateDish(input: GenerateDishInput): Promise<GeneratedDish> {
  const { cuisineId, mealContext, allergies = [] } = input;

  // 获取菜系菜品库
  let dishes = MOCK_DISHES[cuisineId] ?? DEFAULT_DISHES;

  // 根据心情/场景微调
  dishes = selectByMood(dishes, mealContext);

  // 过滤过敏原
  let dish = selectFilteredDish(dishes, allergies);

  // 调整搭配
  const pairings = adjustPairingsByContext(dish.pairings, mealContext);

  return {
    ...dish,
    pairings,
  };
}
