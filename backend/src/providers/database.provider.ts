/**
 * PostgreSQL Database Provider（Supabase/任何PostgreSQL兼容数据库）
 * @module providers/database.provider
 *
 * V2版本从Cloudflare D1切换到PostgreSQL
 * 直接使用pg连接，无需CLI认证
 */
import pg from 'pg';
const { Pool } = pg;

let pool: pg.Pool | null = null;

function getPool(): pg.Pool {
  if (!pool) {
    const connectionString = process.env.POSTGRES_URL;
    if (!connectionString) {
      throw new Error('POSTGRES_URL 环境变量未设置');
    }
    pool = new Pool({
      connectionString,
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });
    pool.on('error', (err) => {
      console.error('[DB] Unexpected error on idle client', err);
    });
  }
  return pool;
}

async function query<T extends pg.QueryResultRow>(
  sql: string,
  params?: unknown[]
): Promise<T[]> {
  const client = await getPool().connect();
  try {
    const result = await client.query<T>(sql, params);
    return result.rows;
  } finally {
    client.release();
  }
}

async function queryOne<T extends pg.QueryResultRow>(
  sql: string,
  params?: unknown[]
): Promise<T | null> {
  const rows = await query<T>(sql, params);
  return rows[0] ?? null;
}

export async function execute(sql: string, params?: unknown[]): Promise<number> {
  const client = await getPool().connect();
  try {
    const result = await client.query(sql, params);
    return result.rowCount ?? 0;
  } finally {
    client.release();
  }
}

// ============ 菜系 ============

export async function getCuisinesByDb() {
  return query<{
    id: string; name: string; name_en: string;
    icon_url: string; cover_image_url: string;
    tags: string; dish_count: number;
  }>('SELECT * FROM cuisines ORDER BY dish_count DESC');
}

export async function getCuisineByIdDb(id: string) {
  return queryOne<{ id: string; name: string }>(
    'SELECT * FROM cuisines WHERE id = $1', [id]
  );
}

export async function getRandomDishByCuisineDb(
  cuisineId: string, excludeIds: string[] = []
) {
  let sql = 'SELECT * FROM dishes WHERE cuisine_id = $1';
  const params: unknown[] = [cuisineId];

  if (excludeIds.length > 0) {
    const placeholders = excludeIds.map((_, i) => `$${i + 2}`).join(',');
    sql += ` AND id NOT IN (${placeholders})`;
    params.push(...excludeIds);
  }
  sql += ' ORDER BY RANDOM() LIMIT 1';
  return queryOne(sql, params);
}

export async function getDishByIdDb(id: string) {
  return queryOne('SELECT * FROM dishes WHERE id = $1', [id]);
}

// ============ 历史记录 ============

export async function insertHistory(
  userId: string, dishId: string, cuisineId: string
) {
  return execute(
    'INSERT INTO recommendation_history (user_id, dish_id, cuisine_id) VALUES ($1, $2, $3)',
    [userId, dishId, cuisineId]
  );
}

export async function getHistoryDb(
  userId: string, page: number, pageSize: number
) {
  const offset = (page - 1) * pageSize;
  return query<{
    id: number; dish_id: string; cuisine_id: string;
    recommended_at: number; liked: number;
    dish_name: string; cuisine_name: string;
  }>(
    `SELECT rh.id, rh.dish_id, rh.cuisine_id, rh.recommended_at, rh.liked,
            d.name as dish_name, c.name as cuisine_name
     FROM recommendation_history rh
     JOIN dishes d ON rh.dish_id = d.id
     JOIN cuisines c ON rh.cuisine_id = c.id
     WHERE rh.user_id = $1
     ORDER BY rh.recommended_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, pageSize, offset]
  );
}

export async function getHistoryCountDb(userId: string) {
  const row = await queryOne<{ count: string }>(
    'SELECT COUNT(*) as count FROM recommendation_history WHERE user_id = $1',
    [userId]
  );
  return row ? parseInt(row.count, 10) : 0;
}

export async function updateFeedbackDb(historyId: number, liked: number) {
  return execute(
    'UPDATE recommendation_history SET liked = $1 WHERE id = $2',
    [liked, historyId]
  );
}

export async function getHistoryByIdDb(historyId: number) {
  return queryOne<{ id: number; user_id: string }>(
    'SELECT * FROM recommendation_history WHERE id = $1', [historyId]
  );
}

// ============ 会话去重（用数据库模拟KV） ============

const SESSION_KEY_PREFIX = 'session_exclusion:';

export async function getExcludedDishesDb(userId: string): Promise<string[]> {
  const row = await queryOne<{ value: string }>(
    'SELECT value FROM session_data WHERE key = $1 AND expires_at > NOW()',
    [`${SESSION_KEY_PREFIX}${userId}`]
  );
  if (!row) return [];
  try {
    return JSON.parse(row.value);
  } catch {
    return [];
  }
}

export async function addExcludedDishDb(
  userId: string, dishId: string
): Promise<void> {
  const key = `${SESSION_KEY_PREFIX}${userId}`;
  const existing = await getExcludedDishesDb(userId);
  const updated = existing.includes(dishId) ? existing : [...existing, dishId];

  await execute(
    `INSERT INTO session_data (key, value, expires_at)
     VALUES ($1, $2, NOW() + INTERVAL '24 hours')
     ON CONFLICT (key) DO UPDATE SET value = $2, expires_at = NOW() + INTERVAL '24 hours'`,
    [key, JSON.stringify(updated)]
  );
}

// ============ 初始化数据库表 ============

export async function initializeDatabase(): Promise<void> {
  // 菜系表
  await execute(`
    CREATE TABLE IF NOT EXISTS cuisines (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      name_en TEXT NOT NULL,
      icon_url TEXT,
      cover_image_url TEXT,
      tags TEXT DEFAULT '[]',
      dish_count INTEGER DEFAULT 0,
      created_at INTEGER DEFAULT (EXTRACT(EPOCH FROM NOW()))::INTEGER,
      updated_at INTEGER DEFAULT (EXTRACT(EPOCH FROM NOW()))::INTEGER
    )
  `);

  // 菜品表
  await execute(`
    CREATE TABLE IF NOT EXISTS dishes (
      id TEXT PRIMARY KEY,
      cuisine_id TEXT NOT NULL,
      name TEXT NOT NULL,
      image_url TEXT,
      thumbnail_url TEXT,
      calories_min INTEGER,
      calories_max INTEGER,
      calories_unit TEXT DEFAULT 'kcal',
      tags TEXT DEFAULT '[]',
      difficulty TEXT,
      cook_time TEXT,
      ai_recommendation TEXT,
      recipe TEXT,
      created_at INTEGER DEFAULT (EXTRACT(EPOCH FROM NOW()))::INTEGER
    )
  `);

  // 推荐历史表
  await execute(`
    CREATE TABLE IF NOT EXISTS recommendation_history (
      id SERIAL PRIMARY KEY,
      user_id TEXT NOT NULL,
      dish_id TEXT NOT NULL,
      cuisine_id TEXT NOT NULL,
      recommended_at INTEGER DEFAULT (EXTRACT(EPOCH FROM NOW()))::INTEGER,
      liked INTEGER DEFAULT 0
    )
  `);

  // 会话数据表（用于去重）
  await execute(`
    CREATE TABLE IF NOT EXISTS session_data (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      expires_at TIMESTAMP NOT NULL
    )
  `);

  // 索引
  await execute(
    'CREATE INDEX IF NOT EXISTS idx_dishes_cuisine ON dishes(cuisine_id)'
  );
  await execute(
    'CREATE INDEX IF NOT EXISTS idx_history_user ON recommendation_history(user_id)'
  );
  await execute(
    'CREATE INDEX IF NOT EXISTS idx_history_user_recent ON recommendation_history(user_id, recommended_at DESC)'
  );
  await execute(
    'CREATE INDEX IF NOT EXISTS idx_session_expires ON session_data(expires_at)'
  );
}
