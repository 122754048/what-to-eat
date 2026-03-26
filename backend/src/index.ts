/**
 * 本地 Node.js 服务器入口（V2 - PostgreSQL版）
 * 用于本地开发和测试
 * 生产部署：Railway/Render/Fly.io
 *
 * @module index
 */
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { serve } from '@hono/node-server';
import { app as honoApp } from './app';
import { initializeDatabase, getCuisinesByDb } from './providers/database.provider';

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

// ============ 初始化接口 ============

// 初始化数据库（创建表）
app.post('/api/v1/init', async (c) => {
  try {
    await initializeDatabase();
    return c.json({ code: 0, message: '数据库初始化成功' });
  } catch (err) {
    console.error('[Init]', err);
    return c.json({ code: 50001, message: '初始化失败', details: String(err) }, 500);
  }
});

// 种子数据接口
app.post('/api/v1/seed', async (c) => {
  try {
    const { initializeDatabase: init, execute: dbExecute } = await import('./providers/database.provider');

    await init();

    // 菜系
    const cuisines = [
      { id: 'chinese_sichuan', name: '川菜', name_en: 'Sichuan', icon_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=200', cover_image_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=800', tags: '["辣","麻辣","经典"]', dish_count: 28 },
      { id: 'chinese_cantonese', name: '粤菜', name_en: 'Cantonese', icon_url: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200', cover_image_url: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800', tags: '["清淡","鲜嫩","养生"]', dish_count: 24 },
      { id: 'chinese_hunan', name: '湘菜', name_en: 'Hunan', icon_url: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=200', cover_image_url: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800', tags: '["辣","酸辣","开胃"]', dish_count: 20 },
      { id: 'chinese_shandong', name: '鲁菜', name_en: 'Shandong', icon_url: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=200', cover_image_url: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800', tags: '["鲜香","咸鲜","清淡"]', dish_count: 18 },
      { id: 'chinese_jiangsu', name: '苏菜', name_en: 'Jiangsu', icon_url: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', cover_image_url: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: '["清淡","甜","精致"]', dish_count: 22 },
    ];

    for (const c of cuisines) {
      await dbExecute(
        `INSERT INTO cuisines (id, name, name_en, icon_url, cover_image_url, tags, dish_count)
         VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT (id) DO UPDATE SET dish_count=EXCLUDED.dish_count`,
        [c.id, c.name, c.name_en, c.icon_url, c.cover_image_url, c.tags, c.dish_count]
      );
    }

    // 菜品
    const dishes = [
      { id: 'dish_kungpao_chicken', cuisine_id: 'chinese_sichuan', name: '宫保鸡丁', image_url: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=200', calories_min: 250, calories_max: 350, tags: '["经典","下饭","微辣"]', difficulty: '简单', cook_time: '25分钟', ai_recommendation: '经典川菜代表，花生与鸡丁的完美碰撞！' },
      { id: 'dish_mapo_tofu', cuisine_id: 'chinese_sichuan', name: '麻婆豆腐', image_url: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=200', calories_min: 180, calories_max: 280, tags: '["经典","麻辣","下饭"]', difficulty: '简单', cook_time: '20分钟', ai_recommendation: '川菜经典，豆腐嫩滑，麻辣鲜香！' },
      { id: 'dish_white_boiled_fish', cuisine_id: 'chinese_cantonese', name: '清蒸鱼', image_url: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=200', calories_min: 150, calories_max: 220, tags: '["清淡","养生","鲜嫩"]', difficulty: '中等', cook_time: '30分钟', ai_recommendation: '粤菜精髓，原汁原味，鱼肉嫩滑！' },
      { id: 'dish_char_siu', cuisine_id: 'chinese_cantonese', name: '叉烧肉', image_url: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200', calories_min: 280, calories_max: 380, tags: '["经典","甜香","色泽红润"]', difficulty: '中等', cook_time: '40分钟', ai_recommendation: '港式经典，外焦里嫩，甜咸交织！' },
      { id: 'dish_chairman_mao_pork', cuisine_id: 'chinese_hunan', name: '毛氏红烧肉', image_url: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=200', calories_min: 350, calories_max: 450, tags: '["经典","色泽红亮","软糯"]', difficulty: '中等', cook_time: '60分钟', ai_recommendation: '湘菜之王，色泽红亮，入口即化！' },
      { id: 'dish_spicy_crayfish', cuisine_id: 'chinese_hunan', name: '口味虾', image_url: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=200', calories_min: 200, calories_max: 300, tags: '["辣","夜宵","过瘾"]', difficulty: '中等', cook_time: '35分钟', ai_recommendation: '湘味十足，辣到飞起又停不下来！' },
      { id: 'dish_degu_braised_prawns', cuisine_id: 'chinese_shandong', name: '德州扒鸡', image_url: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=200', calories_min: 280, calories_max: 380, tags: '["经典","香嫩","脱骨"]', difficulty: '较难', cook_time: '90分钟', ai_recommendation: '鲁菜名吃，肉质软烂，轻轻一抖就脱骨！' },
      { id: 'dish_braised_sea_cucumber', cuisine_id: 'chinese_shandong', name: '葱烧海参', image_url: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=200', calories_min: 150, calories_max: 250, tags: '["高端","滋补","鲜美"]', difficulty: '较难', cook_time: '45分钟', ai_recommendation: '鲁菜经典，海参软糯，葱香四溢！' },
      { id: 'dish_squirrel_fish', cuisine_id: 'chinese_jiangsu', name: '松鼠桂鱼', image_url: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200', calories_min: 220, calories_max: 320, tags: '["经典","酸甜","造型独特"]', difficulty: '较难', cook_time: '50分钟', ai_recommendation: '苏菜代表作，外酥里嫩，酸甜可口！' },
      { id: 'dish_yangzhou_fried_rice', cuisine_id: 'chinese_jiangsu', name: '扬州炒饭', image_url: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', thumbnail_url: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=200', calories_min: 300, calories_max: 400, tags: '["经典","主食","丰盛"]', difficulty: '简单', cook_time: '20分钟', ai_recommendation: '米饭粒粒分明，配料丰富，一碗也是盛宴！' },
    ];

    for (const d of dishes) {
      await dbExecute(
        `INSERT INTO dishes (id, cuisine_id, name, image_url, thumbnail_url, calories_min, calories_max, tags, difficulty, cook_time, ai_recommendation)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
         ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name`,
        [d.id, d.cuisine_id, d.name, d.image_url, d.thumbnail_url, d.calories_min, d.calories_max, d.tags, d.difficulty, d.cook_time, d.ai_recommendation]
      );
    }

    return c.json({ code: 0, message: '种子数据导入成功', data: { cuisines: cuisines.length, dishes: dishes.length } });
  } catch (err) {
    console.error('[Seed]', err);
    return c.json({ code: 50001, message: '种子数据导入失败', details: String(err) }, 500);
  }
});

// 健康检查
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));

// ============ 启动服务器 ============

const PORT = parseInt(process.env.PORT ?? '3000', 10);

console.log(`🚀 「吃什么」后端服务启动中...`);
console.log(`   环境: ${process.env.NODE_ENV ?? 'development'}`);
console.log(`   端口: ${PORT}`);
console.log(`   数据库: ${process.env.POSTGRES_URL ? '已配置' : '❌ 未配置 (需要 POSTGRES_URL)'}`);
console.log('');
console.log(`初始化接口: POST http://localhost:${PORT}/api/v1/init`);
console.log(`种子数据: POST http://localhost:${PORT}/api/v1/seed`);
console.log(`菜系列表: GET http://localhost:${PORT}/api/v1/cuisines`);
console.log('');

serve({
  fetch: app.fetch,
  port: PORT,
});
console.log(`✅ 服务器已启动: http://localhost:${PORT}`);
