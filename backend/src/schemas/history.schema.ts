/**
 * 反馈请求校验 Schema
 * @module schemas/history.schema
 */
import { z } from 'zod';

export const FeedbackBodySchema = z.object({
  liked: z.number().min(-1).max(1).int(),
});

export type FeedbackBody = z.infer<typeof FeedbackBodySchema>;
