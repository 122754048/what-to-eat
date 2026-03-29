/**
 * Cloudflare AI REST API Client
 * @module utils/cloudflare-ai
 *
 * 使用 Cloudflare REST API 调用 AI 模型
 * Account ID + API Token 方式（非 Workers 内置 binding）
 */

export interface CloudflareAIConfig {
  accountId: string;
  apiToken: string;
}

export interface AIMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface AIResponse {
  result: {
    response: string;
  };
}

/**
 * 调用 Cloudflare AI REST API
 */
export async function callCloudflareAI(
  config: CloudflareAIConfig,
  model: string,
  messages: AIMessage[]
): Promise<string> {
  const url = `https://api.cloudflare.com/client/v4/accounts/${config.accountId}/ai/run/${model}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${config.apiToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ messages }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Cloudflare AI API error: ${response.status} ${errorText}`);
  }

  const data = await response.json() as { result: { response: string } };
  return data.result.response;
}

/**
 * 检查是否配置了 Cloudflare AI
 */
export function isCloudflareAIConfigured(): boolean {
  return !!(
    process.env.CLOUDFLARE_ACCOUNT_ID &&
    process.env.CLOUDFLARE_API_TOKEN
  );
}

/**
 * 获取 Cloudflare AI 配置
 */
export function getCloudflareAIConfig(): CloudflareAIConfig {
  return {
    accountId: process.env.CLOUDFLARE_ACCOUNT_ID!,
    apiToken: process.env.CLOUDFLARE_API_TOKEN!,
  };
}
