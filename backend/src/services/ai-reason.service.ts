/**
 * AI推荐理由生成服务
 * @module services/ai-reason.service
 *
 * V2.0：Mock优先，真实AI等凭证到位后切换
 */
export interface GenerateReasonInput {
  dishName: string;
  cuisineName?: string;
}

const REASON_TEMPLATES = [
  '{dish}是{cuisine}代表作，{feature}，吃一口就爱上！',
  '今天吃{cuisine}怎么样？{dish}{feature}，保证让你胃口大开！',
  '{dish}——{cuisine}中的经典，{feature}，下饭神器！',
  '推荐你试试{dish}，{cuisine}的灵魂之选，{feature}！',
  '{dish}，{cuisine}的代表菜，{feature}，不容错过！',
];

const DISH_FEATURES: Record<string, string[]> = {
  辣: ['辣得够劲', '麻辣鲜香', '辣到飞起又停不下来'],
  麻: ['花椒的麻香', '麻与辣的完美融合', '麻到嘴唇在跳舞'],
  酸辣: ['酸辣开胃', '酸辣交织', '酸辣口感一绝'],
  甜: ['甜而不腻', '蜜汁风味', '甜香四溢'],
  鲜: ['鲜嫩多汁', '原汁原味', '鲜到眉毛掉'],
  清淡: ['清淡爽口', '少油健康', '清新不腻'],
  香: ['香气扑鼻', '锅气十足', '香味诱人'],
  嫩: ['嫩滑入口', '肉质软嫩', '滑嫩可口'],
  脆: ['酥脆爽口', '外脆里嫩', '口感层次分明'],
  传统: ['经典传承', '老味道', '记忆中的美味'],
  下饭: ['超下饭', '米饭杀手', '吃撑了还想吃'],
};

// 当没有特定特征时的通用特征
const DEFAULT_FEATURES = [
  '色香味俱全',
  '口感丰富',
  '回味无穷',
  '越吃越香',
  '家常美味',
  '简单易做',
  '营养丰富',
  '老少皆宜',
];

/**
 * 获取菜品特征描述
 */
function getDishFeature(tags: string[]): string {
  for (const tag of tags) {
    const features = DISH_FEATURES[tag];
    if (features) {
      return features[Math.floor(Math.random() * features.length)];
    }
  }
  return DEFAULT_FEATURES[Math.floor(Math.random() * DEFAULT_FEATURES.length)];
}

/**
 * 生成推荐理由（Mock版）
 */
export async function generateReason(input: GenerateReasonInput): Promise<string> {
  const { dishName, cuisineName = '这道菜' } = input;

  // 随机选择模板
  const template = REASON_TEMPLATES[Math.floor(Math.random() * REASON_TEMPLATES.length)];

  // 获取通用特征
  const feature = DEFAULT_FEATURES[Math.floor(Math.random() * DEFAULT_FEATURES.length)];

  return template
    .replace('{dish}', dishName)
    .replace('{cuisine}', cuisineName)
    .replace('{feature}', feature);
}

/**
 * 生成带标签的推荐理由（更个性化）
 */
export async function generateReasonWithTags(
  input: GenerateReasonInput,
  tags: string[] = []
): Promise<string> {
  const { dishName, cuisineName = '这道菜' } = input;

  const template = REASON_TEMPLATES[Math.floor(Math.random() * REASON_TEMPLATES.length)];
  const feature = getDishFeature(tags);

  return template
    .replace('{dish}', dishName)
    .replace('{cuisine}', cuisineName)
    .replace('{feature}', feature);
}
