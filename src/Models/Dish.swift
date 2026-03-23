import Foundation

struct Dish: Identifiable {
    let id = UUID()
    let name: String
    let cuisine: String
    let imageUrl: URL?
}
