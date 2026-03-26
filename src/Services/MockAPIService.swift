import Foundation

// MARK: - Mock API Service
/// Provides mock data for local development and demo purposes.
/// Used when the real backend is unavailable.
class MockAPIService {
    static let shared = MockAPIService()

    private init() {}

    // MARK: - Mock Data

    private let mockCuisines: [Cuisine] = [
        Cuisine(
            id: "chinese_sichuan",
            name: "川菜",
            nameEn: "Sichuan",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1584269600464-37b1b58a9fe1?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1584269600464-37b1b58a9fe1?w=800"),
            dishCount: 28,
            tags: ["辣", "麻辣"]
        ),
        Cuisine(
            id: "chinese_cantonese",
            name: "粤菜",
            nameEn: "Cantonese",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1555126634-323283e090fa?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1555126634-323283e090fa?w=800"),
            dishCount: 35,
            tags: ["清淡", "鲜香"]
        ),
        Cuisine(
            id: "japanese_sushi",
            name: "日料",
            nameEn: "Japanese",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800"),
            dishCount: 22,
            tags: ["新鲜", "精致"]
        ),
        Cuisine(
            id: "italian_pasta",
            name: "意大利菜",
            nameEn: "Italian",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800"),
            dishCount: 18,
            tags: ["浓郁", "芝士"]
        ),
        Cuisine(
            id: "thai_curry",
            name: "泰国菜",
            nameEn: "Thai",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800"),
            dishCount: 15,
            tags: ["酸辣", "香浓"]
        ),
        Cuisine(
            id: "american_burger",
            name: "美式快餐",
            nameEn: "American",
            iconUrl: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200"),
            coverImageUrl: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800"),
            dishCount: 12,
            tags: ["快捷", "量大"]
        )
    ]

    private let mockDishes: [String: Dish] = [
        "chinese_sichuan": Dish(
            id: "dish_kungpao_chicken",
            name: "宫保鸡丁",
            cuisineId: "chinese_sichuan",
            cuisineName: "川菜",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800"),
            thumbnailUrl: URL(string: "https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400"),
            calories: CalorieRange(min: 250, max: 350, unit: "kcal"),
            aiRecommendation: "经典川菜代表，麻辣鲜香，下饭神器！",
            tags: ["经典", "下饭", "麻辣"],
            difficulty: "简单",
            cookTime: "25分钟"
        ),
        "japanese_sushi": Dish(
            id: "dish_sushi_platter",
            name: "寿司拼盘",
            cuisineId: "japanese_sushi",
            cuisineName: "日料",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800"),
            thumbnailUrl: URL(string: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400"),
            calories: CalorieRange(min: 180, max: 280, unit: "kcal"),
            aiRecommendation: "新鲜食材，精致口感，日料入门首选！",
            tags: ["新鲜", "健康", "精致"],
            difficulty: "中等",
            cookTime: "30分钟"
        ),
        "italian_pasta": Dish(
            id: "dish_carbonara",
            name: "意式培根面",
            cuisineId: "italian_pasta",
            cuisineName: "意大利菜",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=800"),
            thumbnailUrl: URL(string: "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400"),
            calories: CalorieRange(min: 400, max: 550, unit: "kcal"),
            aiRecommendation: "浓郁奶油酱配培根，经典意大利风味！",
            tags: ["浓郁", "奶香", "经典"],
            difficulty: "中等",
            cookTime: "20分钟"
        ),
        "thai_curry": Dish(
            id: "dish_green_curry",
            name: "泰式绿咖喱",
            cuisineId: "thai_curry",
            cuisineName: "泰国菜",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=800"),
            thumbnailUrl: URL(string: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400"),
            calories: CalorieRange(min: 300, max: 420, unit: "kcal"),
            aiRecommendation: "酸辣开胃，椰香浓郁，瞬间穿越东南亚！",
            tags: ["酸辣", "椰香", "开胃"],
            difficulty: "简单",
            cookTime: "25分钟"
        ),
        "american_burger": Dish(
            id: "dish_classic_burger",
            name: "经典汉堡",
            cuisineId: "american_burger",
            cuisineName: "美式快餐",
            imageUrl: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800"),
            thumbnailUrl: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400"),
            calories: CalorieRange(min: 450, max: 650, unit: "kcal"),
            aiRecommendation: "肉饼多汁，简单粗暴，汉堡界的经典！",
            tags: ["快捷", "量大", "经典"],
            difficulty: "简单",
            cookTime: "15分钟"
        )
    ]

    // MARK: - Public Mock Methods

    func getCuisines() async throws -> [Cuisine] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockCuisines
    }

    func recommendDish(cuisineId: String, excludePrevious: Bool = true) async throws -> Dish {
        try await Task.sleep(nanoseconds: 800_000_000)

        if let dish = mockDishes[cuisineId] {
            return dish
        }

        let randomDish = mockDishes.values.randomElement()!
        return Dish(
            id: randomDish.id,
            name: randomDish.name,
            cuisineId: cuisineId,
            cuisineName: randomDish.cuisineName,
            imageUrl: randomDish.imageUrl,
            thumbnailUrl: randomDish.thumbnailUrl,
            calories: randomDish.calories,
            aiRecommendation: randomDish.aiRecommendation,
            tags: randomDish.tags,
            difficulty: randomDish.difficulty,
            cookTime: randomDish.cookTime
        )
    }

    func getDishDetail(dishId: String) async throws -> DishDetail {
        try await Task.sleep(nanoseconds: 500_000_000)

        for dish in mockDishes.values {
            if dish.id == dishId {
                return DishDetail(
                    id: dish.id,
                    name: dish.name,
                    cuisineId: dish.cuisineId,
                    cuisineName: dish.cuisineName,
                    imageUrl: dish.imageUrl,
                    thumbnailUrl: dish.thumbnailUrl,
                    calories: dish.calories,
                    aiRecommendation: dish.aiRecommendation,
                    tags: dish.tags,
                    difficulty: dish.difficulty,
                    cookTime: dish.cookTime,
                    recipe: Recipe(
                        ingredients: ["食材1", "食材2", "食材3"],
                        steps: ["步骤1", "步骤2", "步骤3"],
                        tips: "小贴士：注意火候！"
                    )
                )
            }
        }

        throw APIError.serverError(code: 40401, message: "菜品不存在")
    }

    func getHistory(page: Int = 1, pageSize: Int = 20) async throws -> PagedHistory {
        try await Task.sleep(nanoseconds: 500_000_000)
        return PagedHistory(
            items: [],
            page: page,
            pageSize: pageSize,
            total: 0,
            hasMore: false
        )
    }

    func submitFeedback(historyId: String, liked: Int) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
