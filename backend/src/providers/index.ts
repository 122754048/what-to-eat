/**
 * 统一数据访问层
 * 自动检测 Firebase 是否配置，无配置时使用 Mock 数据
 * @module providers
 */

import * as firebaseProvider from './firebase.provider';
import * as mockProvider from './mock.provider';

// 检测 Firebase 是否已初始化
function isFirebaseConfigured(): boolean {
  try {
    // 尝试调用 Firebase，如果未配置会抛错
    const _ = process.env.FIREBASE_SERVICE_ACCOUNT;
    // 简单检查：如果环境变量存在，认为已配置
    return !!process.env.FIREBASE_SERVICE_ACCOUNT;
  } catch {
    return false;
  }
}

const useMock = !isFirebaseConfigured();

// ============ 菜系 ============

export async function getCuisines() {
  if (useMock) return mockProvider.getCuisinesByMock();
  return firebaseProvider.getCuisinesByFirestore();
}

export async function getCuisineById(id: string) {
  if (useMock) return mockProvider.getCuisineByIdMock(id);
  return firebaseProvider.getCuisineByIdFirestore(id);
}

// ============ 菜品 ============

export async function getDishById(id: string) {
  if (useMock) return mockProvider.getDishByIdMock(id);
  return firebaseProvider.getDishByIdFirestore(id);
}

export async function getRandomDishByCuisine(cuisineId: string, excludeIds: string[] = []) {
  if (useMock) return mockProvider.getRandomDishByCuisineMock(cuisineId, excludeIds);
  return firebaseProvider.getRandomDishByCuisineFirestore(cuisineId, excludeIds);
}

// ============ 历史记录 ============

export async function insertHistory(userId: string, dishId: string, cuisineId: string) {
  if (useMock) return mockProvider.insertHistoryMock(userId, dishId, cuisineId);
  return firebaseProvider.insertHistoryFirestore(userId, dishId, cuisineId);
}

export async function getHistory(userId: string, page: number, pageSize: number) {
  if (useMock) return mockProvider.getHistoryMock(userId, page, pageSize);
  return firebaseProvider.getHistoryFirestore(userId, page, pageSize);
}

export async function getHistoryCount(userId: string) {
  if (useMock) return mockProvider.getHistoryCountMock(userId);
  return firebaseProvider.getHistoryCountFirestore(userId);
}

export async function updateFeedback(historyId: string, liked: number) {
  if (useMock) return mockProvider.updateFeedbackMock(historyId, liked);
  return firebaseProvider.updateFeedbackFirestore(historyId, liked);
}

export async function getHistoryById(historyId: string) {
  if (useMock) {
    // Mock 版本需要遍历
    return null;
  }
  return firebaseProvider.getHistoryByIdFirestore(historyId);
}

// ============ 会话去重 ============

export async function getExcludedDishes(userId: string) {
  if (useMock) return mockProvider.getExcludedDishesMock(userId);
  return firebaseProvider.getExcludedDishesFirestore(userId);
}

export async function addExcludedDish(userId: string, dishId: string) {
  if (useMock) return mockProvider.addExcludedDishMock(userId, dishId);
  return firebaseProvider.addExcludedDishFirestore(userId, dishId);
}
