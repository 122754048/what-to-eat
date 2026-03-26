/**
 * Firebase Firestore Provider
 * 使用 Firebase Admin SDK，通过服务账号 JSON 初始化
 *
 * V3 版本：从 Cloudflare D1 → Firebase Firestore
 *
 * 使用方式：
 * 1. 下载 Firebase 服务账号 JSON（项目设置 → 服务账号 → 生成私钥）
 * 2. 将 JSON 内容设置为环境变量 FIREBASE_SERVICE_ACCOUNT
 *    或保存为 google-service-account.json 文件
 */

import * as admin from 'firebase-admin';

// 懒加载初始化
let db: admin.firestore.Firestore | null = null;

function getDb(): admin.firestore.Firestore {
  if (db) return db;

  // 方式1: 环境变量 FIREBASE_SERVICE_ACCOUNT（JSON字符串）
  const envJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (envJson) {
    const serviceAccount = JSON.parse(envJson);
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    db = admin.firestore();
    return db;
  }

  // 方式2: 文件 google-service-account.json
  try {
    const serviceAccount = require('./google-service-account.json');
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    db = admin.firestore();
    return db;
  } catch {
    throw new Error(
      'Firebase 未初始化。请设置 FIREBASE_SERVICE_ACCOUNT 环境变量，或放置 google-service-account.json 文件。'
    );
  }
}

// ============ 菜系操作 ============

export async function getCuisinesByFirestore() {
  const db = getDb();
  const snapshot = await db.collection('cuisines').orderBy('dishCount', 'desc').get();
  return snapshot.docs.map((doc) => doc.data());
}

export async function getCuisineByIdFirestore(id: string) {
  const db = getDb();
  const doc = await db.collection('cuisines').doc(id).get();
  return doc.exists ? doc.data() : null;
}

export async function getRandomDishByCuisineFirestore(
  cuisineId: string,
  excludeIds: string[] = []
) {
  const db = getDb();
  let query: admin.firestore.Query = db.collection('dishes').where('cuisineId', '==', cuisineId);

  if (excludeIds.length > 0) {
    query = query.where('id', 'not-in', excludeIds.slice(0, 10));
  }

  const snapshot = await query.limit(10).get();
  if (snapshot.empty) return null;

  const docs = snapshot.docs;
  const randomDoc = docs[Math.floor(Math.random() * docs.length)];
  return { id: randomDoc.id, ...randomDoc.data() };
}

export async function getDishByIdFirestore(id: string) {
  const db = getDb();
  const doc = await db.collection('dishes').doc(id).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

// ============ 历史记录操作 ============

export async function insertHistoryFirestore(
  userId: string,
  dishId: string,
  cuisineId: string
) {
  const db = getDb();
  const docRef = await db.collection('recommendationHistory').add({
    userId,
    dishId,
    cuisineId,
    recommendedAt: Date.now(),
    liked: 0,
  });
  return docRef.id;
}

export async function getHistoryFirestore(
  userId: string,
  page: number,
  pageSize: number
) {
  const db = getDb();
  const offset = (page - 1) * pageSize;

  const snapshot = await db
    .collection('recommendationHistory')
    .where('userId', '==', userId)
    .orderBy('recommendedAt', 'desc')
    .offset(offset)
    .limit(pageSize)
    .get();

  const docs = snapshot.docs;

  // 获取菜系和菜品名称
  const items = await Promise.all(
    docs.map(async (doc) => {
      const data = doc.data();
      let dishName = '';
      let cuisineName = '';

      try {
        const dishDoc = await db.collection('dishes').doc(data.dishId).get();
        if (dishDoc.exists) {
          dishName = dishDoc.data()?.name ?? '';
          const cuisineId = dishDoc.data()?.cuisineId;
          if (cuisineId) {
            const cuisineDoc = await db.collection('cuisines').doc(cuisineId).get();
            cuisineName = cuisineDoc.data()?.name ?? '';
          }
        }
      } catch { /* ignore */ }

      return {
        id: doc.id,
        dishId: data.dishId,
        dishName,
        cuisineName,
        recommendedAt: data.recommendedAt,
        liked: data.liked ?? 0,
      };
    })
  );

  return items;
}

export async function getHistoryCountFirestore(userId: string) {
  const db = getDb();
  const snapshot = await db
    .collection('recommendationHistory')
    .where('userId', '==', userId)
    .count()
    .get();
  return snapshot.data().count;
}

export async function updateFeedbackFirestore(historyId: string, liked: number) {
  const db = getDb();
  await db.collection('recommendationHistory').doc(historyId).update({ liked });
}

export async function getHistoryByIdFirestore(historyId: string) {
  const db = getDb();
  const doc = await db.collection('recommendationHistory').doc(historyId).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

// ============ 会话去重（Firestore 文档）============

const SESSION_EXCLUSION_PREFIX = 'session_exclusion:';
const SESSION_TTL_MS = 24 * 60 * 60 * 1000; // 24小时

export async function getExcludedDishesFirestore(userId: string): Promise<string[]> {
  const db = getDb();
  const docId = `${SESSION_EXCLUSION_PREFIX}${userId}`;
  const doc = await db.collection('sessionData').doc(docId).get();

  if (!doc.exists) return [];

  const data = doc.data()!;
  const expiresAt = data.expiresAt;

  if (Date.now() > expiresAt) {
    // 已过期，删除
    await doc.ref.delete();
    return [];
  }

  return data.dishIds ?? [];
}

export async function addExcludedDishFirestore(userId: string, dishId: string): Promise<void> {
  const db = getDb();
  const docId = `${SESSION_EXCLUSION_PREFIX}${userId}`;
  const doc = await db.collection('sessionData').doc(docId).get();

  let existing: string[] = [];
  if (doc.exists) {
    const data = doc.data()!;
    if (Date.now() <= data.expiresAt) {
      existing = data.dishIds ?? [];
    }
  }

  if (!existing.includes(dishId)) {
    existing.push(dishId);
  }

  await db.collection('sessionData').doc(docId).set({
    dishIds: existing,
    expiresAt: Date.now() + SESSION_TTL_MS,
  });
}

// ============ 种子数据导入 ============

export async function seedDataFirestore() {
  const db = getDb();

  // 菜系
  const cuisines = [
    { id: 'chinese_sichuan', name: '川菜', nameEn: 'Sichuan', iconUrl: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=800', tags: ['辣', '麻辣', '经典'], dishCount: 28 },
    { id: 'chinese_cantonese', name: '粤菜', nameEn: 'Cantonese', iconUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800', tags: ['清淡', '鲜嫩', '养生'], dishCount: 24 },
    { id: 'chinese_hunan', name: '湘菜', nameEn: 'Hunan', iconUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800', tags: ['辣', '酸辣', '开胃'], dishCount: 20 },
    { id: 'chinese_shandong', name: '鲁菜', nameEn: 'Shandong', iconUrl: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800', tags: ['鲜香', '咸鲜', '清淡'], dishCount: 18 },
    { id: 'chinese_jiangsu', name: '苏菜', nameEn: 'Jiangsu', iconUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', coverImageUrl: 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', tags: ['清淡', '甜', '精致'], dishCount: 22 },
  ];

  for (const c of cuisines) {
    await db.collection('cuisines').doc(c.id).set(c);
  }

  // 菜品
  const dishes = [
    { id: 'dish_kungpao_chicken', cuisineId: 'chinese_sichuan', name: '宫保鸡丁', imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=200', caloriesMin: 250, caloriesMax: 350, caloriesUnit: 'kcal', tags: ['经典', '下饭', '微辣'], difficulty: '简单', cookTime: '25分钟', aiRecommendation: '经典川菜代表，花生与鸡丁的完美碰撞！' },
    { id: 'dish_mapo_tofu', cuisineId: 'chinese_sichuan', name: '麻婆豆腐', imageUrl: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=200', caloriesMin: 180, caloriesMax: 280, caloriesUnit: 'kcal', tags: ['经典', '麻辣', '下饭'], difficulty: '简单', cookTime: '20分钟', aiRecommendation: '川菜经典，豆腐嫩滑，麻辣鲜香！' },
    { id: 'dish_white_boiled_fish', cuisineId: 'chinese_cantonese', name: '清蒸鱼', imageUrl: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=200', caloriesMin: 150, caloriesMax: 220, caloriesUnit: 'kcal', tags: ['清淡', '养生', '鲜嫩'], difficulty: '中等', cookTime: '30分钟', aiRecommendation: '粤菜精髓，原汁原味，鱼肉嫩滑！' },
    { id: 'dish_char_siu', cuisineId: 'chinese_cantonese', name: '叉烧肉', imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200', caloriesMin: 280, caloriesMax: 380, caloriesUnit: 'kcal', tags: ['经典', '甜香', '色泽红润'], difficulty: '中等', cookTime: '40分钟', aiRecommendation: '港式经典，外焦里嫩，甜咸交织！' },
    { id: 'dish_chairman_mao_pork', cuisineId: 'chinese_hunan', name: '毛氏红烧肉', imageUrl: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=200', caloriesMin: 350, caloriesMax: 450, caloriesUnit: 'kcal', tags: ['经典', '色泽红亮', '软糯'], difficulty: '中等', cookTime: '60分钟', aiRecommendation: '湘菜之王，色泽红亮，入口即化！' },
    { id: 'dish_spicy_crayfish', cuisineId: 'chinese_hunan', name: '口味虾', imageUrl: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=200', caloriesMin: 200, caloriesMax: 300, caloriesUnit: 'kcal', tags: ['辣', '夜宵', '过瘾'], difficulty: '中等', cookTime: '35分钟', aiRecommendation: '湘味十足，辣到飞起又停不下来！' },
    { id: 'dish_degu_braised_prawns', cuisineId: 'chinese_shandong', name: '德州扒鸡', imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=200', caloriesMin: 280, caloriesMax: 380, caloriesUnit: 'kcal', tags: ['经典', '香嫩', '脱骨'], difficulty: '较难', cookTime: '90分钟', aiRecommendation: '鲁菜名吃，肉质软烂，轻轻一抖就脱骨！' },
    { id: 'dish_braised_sea_cucumber', cuisineId: 'chinese_shandong', name: '葱烧海参', imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=200', caloriesMin: 150, caloriesMax: 250, caloriesUnit: 'kcal', tags: ['高端', '滋补', '鲜美'], difficulty: '较难', cookTime: '45分钟', aiRecommendation: '鲁菜经典，海参软糯，葱香四溢！' },
    { id: 'dish_squirrel_fish', cuisineId: 'chinese_jiangsu', name: '松鼠桂鱼', imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200', caloriesMin: 220, caloriesMax: 320, caloriesUnit: 'kcal', tags: ['经典', '酸甜', '造型独特'], difficulty: '较难', cookTime: '50分钟', aiRecommendation: '苏菜代表作，外酥里嫩，酸甜可口！' },
    { id: 'dish_yangzhou_fried_rice', cuisineId: 'chinese_jiangsu', name: '扬州炒饭', imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', thumbnailUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=200', caloriesMin: 300, caloriesMax: 400, caloriesUnit: 'kcal', tags: ['经典', '主食', '丰盛'], difficulty: '简单', cookTime: '20分钟', aiRecommendation: '米饭粒粒分明，配料丰富，一碗也是盛宴！' },
  ];

  for (const d of dishes) {
    await db.collection('dishes').doc(d.id).set(d);
  }

  return { cuisines: cuisines.length, dishes: dishes.length };
}
