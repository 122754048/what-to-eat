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
 * 生成推荐理由
 * 注意：V1版本使用预置文案，由前端AI（Cloudflare AI）根据心情/健康目标选择菜系，
 * 后端只负责返回具体菜品，不调用AI。
 * 后续版本可扩展为调用Workers AI生成个性化推荐。
 */
export async function generateAIRecommendation(_dishName: string): Promise<string> {
  return FALLBACK_RECOMMENDATIONS[Math.floor(Math.random() * FALLBACK_RECOMMENDATIONS.length)];
}
