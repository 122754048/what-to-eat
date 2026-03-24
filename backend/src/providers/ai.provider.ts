/**
 * AI Provider（Cloudflare Workers AI）
 * @module providers/ai.provider
 */
import type { Ai } from '@cloudflare/workers-types';

declare const AI: Ai;

const FALLBACK_RECOMMENDATIONS = [
  '经典菜品，口碑极佳，值得一试！',
  '这道菜深受大家喜爱，快来尝尝吧！',
  '香气扑鼻，保证让你胃口大开！',
  '色香味俱全，绝对是下饭神器！',
  '厨房小白也能轻松搞定，快来试试！',
];

/**
 * 生成AI推荐理由（调用Llama 3.1）
 */
export async function generateAIRecommendation(dishName: string): Promise<string> {
  const prompt = `你是一个热情的美食推荐助手。请为"${dishName}"生成一段50字以内的推荐理由，语气友好活泼，突出菜品特点。`;

  try {
    const response = await AI.run('@cf/meta/llama-3-8b-instruct', {
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 100,
      temperature: 0.8,
    }) as { response?: string };

    if (response?.response) {
      // 清理AI输出，去除引号和多余空白
      return response.response.trim().replace(/^[""]|[""]$/g, '');
    }
  } catch (err) {
    console.error('[AI] 生成推荐失败:', err);
  }

  // 降级：随机返回预置文案
  return FALLBACK_RECOMMENDATIONS[Math.floor(Math.random() * FALLBACK_RECOMMENDATIONS.length)];
}
