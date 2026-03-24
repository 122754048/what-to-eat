/**
 * Cloudflare Workers 入口文件
 * @module index
 */
import { setCors } from './middlewares/cors';
import { setErrorHandler } from './middlewares/error';
import { setLogger } from './middlewares/logger';
import { app } from './app';

// 初始化中间件
setCors(app);
setErrorHandler(app);
setLogger(app);

// 导出 workers handler
export default {
  fetch: app.fetch,
};
