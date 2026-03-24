/**
 * 推荐请求校验 Schema
 * @module schemas/recommend.schema
 */
import { z } from 'zod';

export const RecommendBodySchema = z.object({
  excludePrevious: z.boolean().optional().default(true),
});

export type RecommendBody = z.infer<typeof RecommendBodySchema>;
