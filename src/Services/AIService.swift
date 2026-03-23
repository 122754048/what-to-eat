import Foundation

struct AIService {
    
    // Scenario 1: Quick Decide
    func decide(mood: String) async throws -> Dish {
        // Mocked response
        return Dish(name: "Spicy Ramen", cuisine: "Japanese", imageUrl: nil)
    }
    
    // Scenario 2: Explore Cuisine
    func explore(cuisine: String) async throws -> [Dish] {
        // Mocked response
        return [
            Dish(name: "Sushi Platter", cuisine: cuisine, imageUrl: nil),
            Dish(name: "Tempura", cuisine: cuisine, imageUrl: nil),
            Dish(name: "Miso Soup", cuisine: cuisine, imageUrl: nil)
        ]
    }
    
    // Scenario 3: Healthy Mode
    func suggestHealthy(goal: String) async throws -> [Dish] {
        // Mocked response
        return [
            Dish(name: "Grilled Chicken Salad", cuisine: "Healthy", imageUrl: nil),
            Dish(name: "Quinoa Bowl", cuisine: "Healthy", imageUrl: nil)
        ]
    }
}
