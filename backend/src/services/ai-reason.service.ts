/**
 * AI推荐理由生成服务
 * @module services/ai-reason.service
 *
 * V2.0 Phase 1：Mock模板引擎
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

const FEATURES = [
  '色香味俱全',
  '口感丰富',
  '回味无穷',
  '越吃越香',
  '家常美味',
  '简单易做',
  '营养丰富',
  '老少皆宜',
  '下饭神器',
  '开胃必选',
];

/**
 * 生成推荐理由（Mock版）
 */
export async function generateReason(input: GenerateReasonInput): Promise<string> {
  const { dishName, cuisineName = '这道菜' } = input;

  const template = REASON_TEMPLATES[Math.floor(Math.random() * REASON_TEMPLATES.length)];
  const feature = FEATURES[Math.floor(Math.random() * FEATURES.length)];

  return template
    .replace('{dish}', dishName)
    .replace('{cuisine}', cuisineName)
    .replace('{feature}', feature);
}
