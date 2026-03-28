import Foundation

// MARK: - API Configuration
enum APIConfig {
    // Set to true to use mock data (for demo without backend)
    static let useMock = false

    #if DEBUG
    static let baseURL = "https://passionate-rejoicing-production.up.railway.app/api/v1"
    #else
    static let baseURL = "https://passionate-rejoicing-production.up.railway.app/api/v1"
    #endif

    static let userIDKey = "device_uuid"
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(code: Int, message: String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(_, let message):
            return message
        case .decodingError:
            return "数据解析失败"
        }
    }
}

// MARK: - API Response
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

// MARK: - Models
struct Cuisine: Identifiable, Codable {
    let id: String
    let name: String
    let nameEn: String
    let iconUrl: URL?
    let coverImageUrl: URL?
    let dishCount: Int
    let tags: [String]
}

struct Dish: Identifiable, Codable {
    let id: String
    let name: String
    let cuisineId: String
    let cuisineName: String
    let imageUrl: URL?
    let thumbnailUrl: URL?
    let calories: CalorieRange?
    let aiRecommendation: String?
    let tags: [String]
    let difficulty: String?
    let cookTime: String?
}

struct CalorieRange: Codable {
    let min: Int
    let max: Int
    let unit: String
}

struct DishDetail: Identifiable, Codable {
    let id: String
    let name: String
    let cuisineId: String
    let cuisineName: String
    let imageUrl: URL?
    let thumbnailUrl: URL?
    let calories: CalorieRange?
    let aiRecommendation: String?
    let tags: [String]
    let difficulty: String?
    let cookTime: String?
    let recipe: Recipe?
}

struct Recipe: Codable {
    let ingredients: [String]
    let steps: [String]
    let tips: String?
}

struct HistoryItem: Identifiable, Codable {
    let id: String
    let dish: Dish
    let liked: Int?
    let createdAt: String
}

struct PagedHistory: Codable {
    let items: [HistoryItem]
    let page: Int
    let pageSize: Int
    let total: Int
    let hasMore: Bool
}

// MARK: - Device UUID
class DeviceUUID {
    static func getOrCreate() -> String {
        if let uuid = UserDefaults.standard.string(forKey: APIConfig.userIDKey) {
            return uuid
        }
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: APIConfig.userIDKey)
        return newUUID
    }
}

// MARK: - API Service
class APIService {
    static let shared = APIService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Private Helpers

    private func request<T: Codable>(
        method: String,
        endpoint: String,
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(DeviceUUID.getOrCreate(), forHTTPHeaderField: "X-User-ID")

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(code: httpResponse.statusCode, message: "服务器错误")
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            if decoded.code == 0 {
                guard let responseData = decoded.data else {
                    throw APIError.serverError(code: decoded.code, message: "响应数据为空")
                }
                return responseData
            } else {
                throw APIError.serverError(code: decoded.code, message: decoded.message)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - API Endpoints

    func getCuisines() async throws -> [Cuisine] {
        struct Response: Codable {
            let cuisines: [Cuisine]
        }
        let response: Response = try await request(method: "GET", endpoint: "/cuisines")
        return response.cuisines
    }

    func recommendDish(cuisineId: String, excludePrevious: Bool = true) async throws -> Dish {
        struct Response: Codable {
            let dish: Dish
        }
        let body: [String: Any] = ["excludePrevious": excludePrevious]
        let response: Response = try await request(
            method: "POST",
            endpoint: "/recommend/cuisines/\(cuisineId)/recommend",
            body: body
        )
        return response.dish
    }

    func getDishDetail(dishId: String) async throws -> DishDetail {
        return try await request(method: "GET", endpoint: "/dishes/\(dishId)")
    }

    func getHistory(page: Int = 1, pageSize: Int = 20) async throws -> PagedHistory {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        return try await request(method: "GET", endpoint: "/history", queryItems: queryItems)
    }

    func submitFeedback(historyId: String, liked: Int) async throws {
        struct EmptyResponse: Codable {}
        let body: [String: Any] = ["liked": liked]
        let _: EmptyResponse = try await request(
            method: "POST",
            endpoint: "/history/\(historyId)/feedback",
            body: body
        )
    }
}
