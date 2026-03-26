/**
 * AI菜品生成服务
 * @module services/ai-dish.service
 *
 * V2.0：Mock优先，真实AI等凭证到位后切换
 */
export interface GenerateDishInput {
  cuisineId: string;
  dietaryRestrictions?: string[]; // 忌口
  mood?: string;                 // 心情
}

export interface GeneratedDish {
  name: string;
  cuisineId: string;
  cuisineName: string;
  description: string;
  ingredients: string[];
  cookTime: string;
  difficulty: string;
  imagePrompt: string;   // AI图片生成prompt
  calories: { min: number; max: number; unit: string };
  tags: string[];
  dietaryNote?: string; // 适配忌口的说明
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

// Mock菜品库（按菜系分类）
const MOCK_DISHES: Record<string, GeneratedDish[]> = {
  chinese_sichuan: [
    {
      name: '水煮牛肉',
      cuisineId: 'chinese_sichuan',
      cuisineName: '川菜',
      description: '麻辣鲜香，牛肉嫩滑，热油激香',
      ingredients: ['牛肉片', '豆芽', '莴笋', '花椒', '干辣椒', '郫县豆瓣'],
      cookTime: '25分钟',
      difficulty: '中等',
      imagePrompt: '水煮牛肉，麻辣四川菜，红油汤底，牛肉片配蔬菜',
      calories: { min: 300, max: 400, unit: 'kcal' },
      tags: ['辣', '下饭', '经典'],
    },
    {
      name: '酸菜鱼',
      cuisineId: 'chinese_sichuan',
      cuisineName: '川菜',
      description: '酸辣开胃，鱼肉鲜嫩，汤汁浓郁',
      ingredients: ['黑鱼片', '酸菜', '泡椒', '豆芽', '粉丝'],
      cookTime: '20分钟',
      difficulty: '简单',
      imagePrompt: '酸菜鱼，川菜，酸辣口味，鱼片配酸菜',
      calories: { min: 200, max: 300, unit: 'kcal' },
      tags: ['酸辣', '开胃', '低脂'],
    },
    {
      name: '干煸四季豆',
      cuisineId: 'chinese_sichuan',
      cuisineName: '川菜',
      description: '干香入味，四季豆脆嫩，下饭神器',
      ingredients: ['四季豆', '肉末', '干辣椒', '花椒', '蒜末'],
      cookTime: '15分钟',
      difficulty: '简单',
      imagePrompt: '干煸四季豆，川菜，干辣椒肉末炒四季豆',
      calories: { min: 150, max: 200, unit: 'kcal' },
      tags: ['香辣', '下饭', '素菜'],
      dietaryNote: '可选不放肉末，做成纯素版本',
    },
    {
      name: '回锅肉',
      cuisineId: 'chinese_sichuan',
      cuisineName: '川菜',
      description: '肥而不腻，色泽红亮，蒜香浓郁',
      ingredients: ['五花肉', '青蒜', '郫县豆瓣', '甜面酱', '花椒'],
      cookTime: '30分钟',
      difficulty: '中等',
      imagePrompt: '回锅肉，川菜经典，蒜苗回锅肉，色泽红亮',
      calories: { min: 350, max: 450, unit: 'kcal' },
      tags: ['经典', '下饭', '香辣'],
    },
    {
      name: '宫保鸡丁',
      cuisineId: 'chinese_sichuan',
      cuisineName: '川菜',
      description: '糊辣荔枝口，花生酥脆，鸡丁嫩滑',
      ingredients: ['鸡胸肉', '花生米', '干辣椒', '花椒', '葱段'],
      cookTime: '25分钟',
      difficulty: '简单',
      imagePrompt: '宫保鸡丁，川菜经典，鸡肉花生辣椒',
      calories: { min: 250, max: 350, unit: 'kcal' },
      tags: ['经典', '下饭', '微辣'],
    },
  ],
  chinese_cantonese: [
    {
      name: '白切鸡',
      cuisineId: 'chinese_cantonese',
      cuisineName: '粤菜',
      description: '皮爽肉滑，原汁原味，姜葱酱料绝配',
      ingredients: ['三黄鸡', '姜', '葱', '沙姜', '花生油'],
      cookTime: '40分钟',
      difficulty: '中等',
      imagePrompt: '白切鸡，粤菜经典，皮黄肉嫩，配姜葱酱',
      calories: { min: 200, max: 280, unit: 'kcal' },
      tags: ['清淡', '鲜美', '经典'],
    },
    {
      name: '清蒸石斑',
      cuisineId: 'chinese_cantonese',
      cuisineName: '粤菜',
      description: '鱼肉鲜嫩，清淡少油，保留海鲜原味',
      ingredients: ['石斑鱼', '葱丝', '姜丝', '蒸鱼豉油', '热油'],
      cookTime: '15分钟',
      difficulty: '简单',
      imagePrompt: '清蒸石斑鱼，粤菜，葱姜铺面，鲜嫩白皙',
      calories: { min: 120, max: 180, unit: 'kcal' },
      tags: ['清淡', '养生', '海鲜'],
    },
    {
      name: '叉烧肉',
      cuisineId: 'chinese_cantonese',
      cuisineName: '粤菜',
      description: '外焦里嫩，甜香四溢，港式经典',
      ingredients: ['梅花肉', '叉烧酱', '蜂蜜', '红曲粉'],
      cookTime: '40分钟',
      difficulty: '中等',
      imagePrompt: '叉烧肉，粤菜港式，色泽红亮，蜜汁叉烧',
      calories: { min: 280, max: 380, unit: 'kcal' },
      tags: ['甜香', '经典', '下饭'],
    },
    {
      name: '上汤娃娃菜',
      cuisineId: 'chinese_cantonese',
      cuisineName: '粤菜',
      description: '汤鲜菜嫩，清淡爽口，老少皆宜',
      ingredients: ['娃娃菜', '皮蛋', '咸蛋', '火腿', '高汤'],
      cookTime: '15分钟',
      difficulty: '简单',
      imagePrompt: '上汤娃娃菜，粤菜，清淡汤菜，绿色蔬菜',
      calories: { min: 80, max: 120, unit: 'kcal' },
      tags: ['清淡', '养生', '素菜'],
      dietaryNote: '低脂低热量，适合减脂人群',
    },
    {
      name: '豉汁蒸排骨',
      cuisineId: 'chinese_cantonese',
      cuisineName: '粤菜',
      description: '豆豉香浓，排骨软糯，蒸制更健康',
      ingredients: ['猪肋排', '豆豉', '蒜末', '生抽', '糖'],
      cookTime: '35分钟',
      difficulty: '中等',
      imagePrompt: '豉汁蒸排骨，粤菜，豆豉排骨，软糯入味',
      calories: { min: 250, max: 350, unit: 'kcal' },
      tags: ['鲜香', '蒸菜', '经典'],
    },
  ],
  chinese_hunan: [
    {
      name: '剁椒鱼头',
      cuisineId: 'chinese_hunan',
      cuisineName: '湘菜',
      description: '剁椒铺满鱼头，鲜辣过瘾，汤汁拌面一绝',
      ingredients: ['鳙鱼头', '剁椒', '豆豉', '葱姜', '料酒'],
      cookTime: '20分钟',
      difficulty: '简单',
      imagePrompt: '剁椒鱼头，湘菜经典，红剁椒铺面，鲜辣',
      calories: { min: 200, max: 300, unit: 'kcal' },
      tags: ['辣', '开胃', '经典'],
    },
    {
      name: '小炒黄牛肉',
      cuisineId: 'chinese_hunan',
      cuisineName: '湘菜',
      description: '猛火爆炒，牛肉嫩滑，泡椒提味',
      ingredients: ['黄牛肉', '泡椒', '小米辣', '香菜', '蒜片'],
      cookTime: '10分钟',
      difficulty: '简单',
      imagePrompt: '小炒黄牛肉，湘菜，泡椒牛肉，麻辣鲜香',
      calories: { min: 200, max: 280, unit: 'kcal' },
      tags: ['辣', '下饭', '快手'],
    },
    {
      name: '毛氏红烧肉',
      cuisineId: 'chinese_hunan',
      cuisineName: '湘菜',
      description: '色泽红亮，肥而不腻，入口即化',
      ingredients: ['五花肉', '冰糖', '八角', '桂皮', '生抽'],
      cookTime: '60分钟',
      difficulty: '中等',
      imagePrompt: '毛氏红烧肉，湘菜经典，红烧肉色泽红亮',
      calories: { min: 400, max: 500, unit: 'kcal' },
      tags: ['经典', '软糯', '下饭'],
    },
    {
      name: '腊味合蒸',
      cuisineId: 'chinese_hunan',
      cuisineName: '湘菜',
      description: '腊肉腊肠同蒸，香味交融，下饭绝佳',
      ingredients: ['腊肉', '腊肠', '豆豉', '干辣椒', '蒜'],
      cookTime: '25分钟',
      difficulty: '简单',
      imagePrompt: '腊味合蒸，湘菜，腊肉腊肠蒸制，咸香',
      calories: { min: 300, max: 400, unit: 'kcal' },
      tags: ['咸香', '下饭', '传统'],
    },
  ],
  healthy: [
    {
      name: '藜麦鸡胸沙拉',
      cuisineId: 'healthy',
      cuisineName: '健康餐',
      description: '高蛋白低脂肪，藜麦饱腹，鸡胸肉嫩滑',
      ingredients: ['藜麦', '鸡胸肉', '牛油果', '小番茄', '苦苣'],
      cookTime: '20分钟',
      difficulty: '简单',
      imagePrompt: '藜麦鸡胸肉沙拉，健康餐，五彩蔬菜鸡胸',
      calories: { min: 350, max: 450, unit: 'kcal' },
      tags: ['低脂', '高蛋白', '减脂'],
      dietaryNote: '适合减脂人群，高蛋白低脂肪',
    },
    {
      name: '西兰花虾仁',
      cuisineId: 'healthy',
      cuisineName: '健康餐',
      description: '清炒少油，虾仁Q弹，西兰花脆嫩',
      ingredients: ['西兰花', '虾仁', '蒜末', '橄榄油', '盐'],
      cookTime: '10分钟',
      difficulty: '简单',
      imagePrompt: '西兰花虾仁，健康餐，清炒虾仁配西兰花',
      calories: { min: 150, max: 200, unit: 'kcal' },
      tags: ['低脂', '高蛋白', '快手'],
      dietaryNote: '少油烹饪，适合减脂',
    },
    {
      name: '三文鱼牛油果碗',
      cuisineId: 'healthy',
      cuisineName: '健康餐',
      description: 'Omega-3丰富，三文鱼嫩滑，牛油果绵密',
      ingredients: ['三文鱼', '牛油果', '糙米', '紫甘蓝', '芝麻酱'],
      cookTime: '25分钟',
      difficulty: '简单',
      imagePrompt: '三文鱼牛油果碗，网红健康餐，色彩丰富',
      calories: { min: 450, max: 550, unit: 'kcal' },
      tags: ['高蛋白', 'Omega-3', '减脂'],
      dietaryNote: '优质脂肪来源，适合健身人群',
    },
    {
      name: '番茄龙利鱼',
      cuisineId: 'healthy',
      cuisineName: '健康餐',
      description: '酸甜开胃，龙利鱼无骨无刺，嫩滑可口',
      ingredients: ['龙利鱼', '番茄', '金针菇', '番茄酱', '姜丝'],
      cookTime: '20分钟',
      difficulty: '简单',
      imagePrompt: '番茄龙利鱼，健康餐，酸甜番茄汤配嫩滑鱼肉',
      calories: { min: 180, max: 250, unit: 'kcal' },
      tags: ['低脂', '高蛋白', '清淡'],
      dietaryNote: '龙利鱼无刺，适合老人小孩',
    },
  ],
};

// 默认菜品（未知菜系时使用）
const DEFAULT_DISHES: GeneratedDish[] = [
  {
    name: '香煎鸡胸肉配蔬菜',
    cuisineId: 'default',
    cuisineName: '创意菜',
    description: '外焦里嫩，营养均衡，健康美味',
    ingredients: ['鸡胸肉', '西兰花', '胡萝卜', '橄榄油', '黑胡椒'],
    cookTime: '20分钟',
    difficulty: '简单',
    imagePrompt: '香煎鸡胸肉配蔬菜，健康餐盘，色彩丰富',
    calories: { min: 300, max: 380, unit: 'kcal' },
    tags: ['健康', '高蛋白', '减脂'],
  },
  {
    name: '蒜蓉蒸虾',
    cuisineId: 'default',
    cuisineName: '创意菜',
    description: '蒜香浓郁，虾肉鲜甜，蒸制更健康',
    ingredients: ['大虾', '蒜末', '葱花', '粉丝', '蒸鱼豉油'],
    cookTime: '15分钟',
    difficulty: '简单',
    imagePrompt: '蒜蓉蒸虾，海鲜，蒜末铺面，鲜嫩大虾',
    calories: { min: 150, max: 220, unit: 'kcal' },
    tags: ['海鲜', '低脂', '鲜甜'],
  },
];

/**
 * 忌口关键词过滤规则
 */
const DIETARY_FILTERS: Record<string, (dish: GeneratedDish) => boolean> = {
  '不辣': (d) => !d.tags.includes('辣') && !d.tags.includes('麻辣') && !d.tags.includes('酸辣'),
  '少油': (d) => d.calories.max < 350,
  '清淡': (d) => d.tags.includes('清淡') || d.tags.includes('养生'),
  '素': (d) => d.dietaryNote?.includes('素') || d.ingredients.every(i => !['肉', '鱼', '虾', '鸡', '猪', '牛', '羊'].some(m => i.includes(m))),
  '减脂': (d) => d.tags.includes('低脂') || d.tags.includes('减脂'),
  '低脂': (d) => d.tags.includes('低脂'),
  '高蛋白': (d) => d.tags.includes('高蛋白'),
  '无辣': (d) => !d.tags.includes('辣'),
};

/**
 * 根据忌口过滤菜品
 */
function filterByDietaryRestrictions(
  dishes: GeneratedDish[],
  restrictions: string[]
): { dish: GeneratedDish; note?: string } {
  if (restrictions.length === 0) {
    return { dish: dishes[Math.floor(Math.random() * dishes.length)] };
  }

  // 尝试找到完全满足的
  let candidates = dishes;
  for (const restriction of restrictions) {
    const filter = DIETARY_FILTERS[restriction];
    if (filter) {
      candidates = candidates.filter(filter);
    }
  }

  if (candidates.length > 0) {
    return { dish: candidates[Math.floor(Math.random() * candidates.length)] };
  }

  // 没找到完全满足的，返回热量最低的并加说明
  const sortedByCalories = [...dishes].sort((a, b) => a.calories.max - b.calories.max);
  return {
    dish: sortedByCalories[0],
    note: `注：无法完全满足"${restrictions.join('、')}，已选择最接近的选项`,
  };
}

/**
 * 生成AI菜品
 * V2.0：使用Mock数据，真实AI等凭证到位后切换
 */
export async function generateDish(input: GenerateDishInput): Promise<GeneratedDish & { dietaryNote?: string }> {
  const { cuisineId, dietaryRestrictions = [], mood } = input;

  // 获取菜系菜品库
  const dishes = MOCK_DISHES[cuisineId] ?? DEFAULT_DISHES;

  // 过滤忌口
  const { dish, note } = filterByDietaryRestrictions(dishes, dietaryRestrictions);

  // 根据心情微调（简单规则）
  let finalDish = { ...dish };
  if (mood) {
    if (mood.includes('辣') || mood.includes('重口')) {
      // 选辣的
      const spicy = dishes.filter(d => d.tags.includes('辣') || d.tags.includes('麻辣'));
      if (spicy.length > 0) {
        finalDish = spicy[Math.floor(Math.random() * spicy.length)];
      }
    } else if (mood.includes('清淡') || mood.includes('健康')) {
      // 选清淡的
      const light = dishes.filter(d => d.tags.includes('清淡') || d.tags.includes('养生'));
      if (light.length > 0) {
        finalDish = light[Math.floor(Math.random() * light.length)];
      }
    }
  }

  // 强制使用请求的cuisineId
  finalDish.cuisineId = cuisineId;
  finalDish.cuisineName = CUISINE_NAMES[cuisineId] ?? CUISINE_NAMES.default;

  if (note) {
    finalDish.dietaryNote = note;
  }

  return finalDish;
}
