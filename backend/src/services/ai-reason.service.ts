/**
 * AI推荐理由生成服务
 * @module services/ai-reason.service
 *
 * V2.0 Phase 2：优先 Cloudflare AI REST API，fallback Mock
 */
import {
  isCloudflareAIConfigured,
  getCloudflareAIConfig,
  callCloudflareAI,
  AIMessage,
} from '../utils/cloudflare-ai';

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
 * 生成推荐理由
 * 优先调用 Cloudflare AI，fallback Mock
 */
export async function generateReason(input: GenerateReasonInput): Promise<string> {
  const { dishName, cuisineName = '这道菜' } = input;

  // 尝试调用 Cloudflare AI
  if (isCloudflareAIConfigured()) {
    try {
      const config = getCloudflareAIConfig();
      const messages: AIMessage[] = [
        {
          role: 'user',
          content: `你是一个美食推荐助手。请为"${dishName}"（${cuisineName}）生成一句简短的推荐理由，不超过20个字，要生动诱人。只需返回推荐理由，不要其他文字。`,
        },
      ];

      const response = await callCloudflareAI(config, '@cf/meta/llama-4-scout-b', messages);
      const reason = response.trim();
      if (reason.length > 0 && reason.length <= 50) {
        return reason;
      }
    } catch (err) {
      console.warn('[AI Reason] Cloudflare AI 调用失败，使用 Mock fallback:', err);
    }
  }

  // ========== Mock fallback ==========
  const template = REASON_TEMPLATES[Math.floor(Math.random() * REASON_TEMPLATES.length)];
  const feature = FEATURES[Math.floor(Math.random() * FEATURES.length)];

  return template
    .replace('{dish}', dishName)
    .replace('{cuisine}', cuisineName)
    .replace('{feature}', feature);
}
