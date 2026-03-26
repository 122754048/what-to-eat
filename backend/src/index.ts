/**
 * 本地 Node.js 服务器入口（Firebase 版）
 * 用于本地开发和测试
 * 生产部署：Firebase Cloud Functions / Railway / Render
 *
 * @module index
 */
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { serve } from '@hono/node-server';
import { app as honoApp } from './app';
import { seedDataFirestore } from './providers/firebase.provider';

const app = new Hono();

// ============ 中间件 ============

app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'X-User-ID'],
}));

app.use('*', async (c, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`[${new Date().toISOString()}] ${c.req.method} ${c.req.path} ${c.res.status} - ${ms}ms`);
});

app.onError((err, c) => {
  console.error('[Error]', err.message);
  return c.json({ code: 50001, message: '服务端内部错误', details: null }, 500);
});

// ============ 挂载 Hono 路由 ============

app.route('/api/v1', honoApp);

// ============ Firebase 专用接口 ============

// 种子数据导入（Firebase）
app.post('/api/v1/firebase/seed', async (c) => {
  try {
    const result = await seedDataFirestore();
    return c.json({ code: 0, message: '种子数据导入成功', data: result });
  } catch (err) {
    console.error('[Seed]', err);
    return c.json({ code: 50001, message: '种子数据导入失败', details: String(err) }, 500);
  }
});

// 健康检查
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));

// ============ 启动服务器 ============

const PORT = parseInt(process.env.PORT ?? '3000', 10);

console.log(`🚀 「吃什么」后端服务（Firebase版）启动中...`);
console.log(`   环境: ${process.env.NODE_ENV ?? 'development'}`);
console.log(`   端口: ${PORT}`);
console.log(`   Firebase: ${process.env.FIREBASE_SERVICE_ACCOUNT || './google-service-account.json'}`);
console.log('');
console.log(`种子数据: POST http://localhost:${PORT}/api/v1/firebase/seed`);
console.log(`菜系列表: GET http://localhost:${PORT}/api/v1/cuisines`);
console.log('');
console.log(`初始化步骤:`);
console.log(`1. 确保设置了 FIREBASE_SERVICE_ACCOUNT 环境变量`);
console.log(`2. 或将服务账号 JSON 保存为 ./google-service-account.json`);
console.log(`3. POST /api/v1/firebase/seed 导入种子数据`);
console.log('');

serve({
  fetch: app.fetch,
  port: PORT,
});
console.log(`✅ 服务器已启动: http://localhost:${PORT}`);
