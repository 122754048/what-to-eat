import Foundation

// MARK: - AI Service Configuration
enum AIConfig {
    static let cloudflareAccountId = "YOUR_CLOUDFLARE_ACCOUNT_ID"
    static let cloudflareBaseURL = "https://api.cloudflare.com/client/v4/accounts/\(cloudflareAccountId)/ai/run"
    static let model = "@cf/meta/llama-3.1-8b-instruct"

    // Fallback cuisines for when AI is unavailable
    static let fallbackCuisines: [String: String] = [
        "辣": "chinese_sichuan",
        "川菜": "chinese_sichuan",
        "清淡": "chinese_cantonese",
        "健康": "healthy_salad",
        "减脂": "healthy_salad",
        "日料": "japanese_sushi",
        "西餐": "western_steak",
        "快餐": "american_burger",
        "意大利": "italian_pasta",
        "泰国": "thai_curry",
        "韩国": "korean_bbq",
        "印度": "indian_curry",
        "越南": "vietnamese_pho",
        "素食": "vegetarian_bowl",
        "早餐": "breakfast_noodles"
    ]
}

// MARK: - AI Error
enum AIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case aiServiceUnavailable
    case parsingError
    case noCuisineRecommended

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "AI 服务配置错误"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .aiServiceUnavailable:
            return "AI 服务暂时不可用"
        case .parsingError:
            return "AI 返回格式解析失败"
        case .noCuisineRecommended:
            return "无法理解您的需求，请换个说法"
        }
    }
}

// MARK: - AI Response
struct CloudflareAIResponse: Codable {
    let result: AIResult?

    struct AIResult: Codable {
        let response: String
    }
}

// MARK: - AI Service
/// Handles direct calls to Cloudflare Workers AI for cuisine recommendations
class AIService {
    static let shared = AIService()

    private let session: URLSession
    private let apiService = APIService.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public APIs

    /// Decide a dish based on user's mood
    /// - Parameter mood: user's mood or preference description
    /// - Returns: a recommended dish
    func decide(mood: String) async throws -> Dish {
        let cuisineId = try await getCuisineIdFromAI(
            prompt: "用户心情：\(mood)。请推荐一个最合适的菜系，只输出菜系ID，格式为纯文本。",
            fallbackKey: mood
        )
        return try await apiService.recommendDish(cuisineId: cuisineId)
    }

    /// Explore dishes within a specific cuisine
    /// - Parameter cuisine: cuisine name or ID
    /// - Returns: a random dish from that cuisine
    func explore(cuisine: String) async throws -> Dish {
        // Try to match cuisine string to a known cuisineId
        let cuisineId = AIConfig.fallbackCuisines[cuisine] ?? cuisine
        return try await apiService.recommendDish(cuisineId: cuisineId)
    }

    /// Get a healthy dish recommendation based on user's health goal
    /// - Parameter goal: user's health goal (e.g., "减脂", "高蛋白")
    /// - Returns: a recommended healthy dish
    func suggestHealthy(goal: String) async throws -> Dish {
        let cuisineId = try await getCuisineIdFromAI(
            prompt: "用户健康目标：\(goal)。请推荐最适合这个健康目标的菜系，只输出菜系ID，格式为纯文本。",
            fallbackKey: goal
        )
        return try await apiService.recommendDish(cuisineId: cuisineId)
    }

    // MARK: - Private Helpers

    /// Call Cloudflare AI to get a cuisineId based on a text prompt
    private func getCuisineIdFromAI(prompt: String, fallbackKey: String) async throws -> String {
        guard let url = URL(string: "\(AIConfig.cloudflareBaseURL)/\(AIConfig.model)") else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getCloudflareAPIToken())", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 50,
            "temperature": 0.3
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.networkError(URLError(.badServerResponse))
            }

            guard httpResponse.statusCode == 200 else {
                // If AI service fails, fall back to keyword matching
                if let fallback = AIConfig.fallbackCuisines[fallbackKey] {
                    return fallback
                }
                throw AIError.aiServiceUnavailable
            }

            let aiResponse = try JSONDecoder().decode(CloudflareAIResponse.self, from: data)
            let aiText = aiResponse.result?.response.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // Try to extract cuisineId from AI response
            // AI might return something like "chinese_sichuan" or "推荐川菜 (chinese_sichuan)"
            if let cuisineId = extractCuisineId(from: aiText) {
                return cuisineId
            }

            // Fallback: try to match the response text to a known cuisine
            for (key, value) in AIConfig.fallbackCuisines {
                if aiText.contains(key) || aiText.contains(value) {
                    return value
                }
            }

            // Last resort fallback
            if let fallback = AIConfig.fallbackCuisines[fallbackKey] {
                return fallback
            }

            throw AIError.noCuisineRecommended

        } catch let error as AIError {
            throw error
        } catch {
            // Network or other error, try fallback
            if let fallback = AIConfig.fallbackCuisines[fallbackKey] {
                return fallback
            }
            throw AIError.networkError(error)
        }
    }

    /// Extract a cuisineId from AI's free-form text response
    private func extractCuisineId(from text: String) -> String? {
        // The text might be just the cuisineId like "chinese_sichuan"
        // or it might contain the cuisineId in parentheses like "川菜 (chinese_sichuan)"
        let pattern = #"([a-z_]+_[a-z_]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return nil
        }
        return String(text[range])
    }

    private func getCloudflareAPIToken() -> String {
        // In production, this should come from a secure storage or environment
        // For now, we use a placeholder that should be replaced with actual token
        return ProcessInfo.processInfo.environment["CLOUDFLARE_API_TOKEN"] ?? ""
    }
}
