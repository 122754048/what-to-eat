import SwiftUI

// MARK: - History Manager (Local Storage)
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()

    private let key = "swipe_history"

    struct HistoryEntry: Identifiable, Codable {
        let id: String
        let dish: Dish
        let liked: Int  // 1 = liked, -1 = skipped, 0 = undecided
        let timestamp: Date
    }

    @Published private(set) var entries: [HistoryEntry] = []

    private init() {
        load()
    }

    func add(dish: Dish, liked: Int) {
        let entry = HistoryEntry(
            id: UUID().uuidString,
            dish: dish,
            liked: liked,
            timestamp: Date()
        )
        entries.insert(entry, at: 0)
        save()
    }

    func remove(at index: Int) {
        guard index < entries.count else { return }
        entries.remove(at: index)
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return
        }
        entries = decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Design.Colors.background
                    .ignoresSafeArea()

                if historyManager.entries.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle("历史记录")
        }
    }

    private var emptyState: some View {
        VStack(spacing: Design.Spacing.cardMargin) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(Design.Colors.secondaryText)

            Text("暂无历史记录")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Design.Colors.primaryText)

            Text("快去滑动卡片探索美食吧")
                .font(.body)
                .foregroundColor(Design.Colors.secondaryText)
        }
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: Design.Spacing.standard) {
                ForEach(historyManager.entries) { entry in
                    HistoryRow(entry: entry)
                }
            }
            .padding(Design.Spacing.screenPadding)
        }
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let entry: HistoryManager.HistoryEntry

    var body: some View {
        HStack(spacing: Design.Spacing.cardPadding) {
            // Dish Image
            AsyncImage(url: entry.dish.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Design.Colors.cardBackground)
                }
            }
            .frame(width: 70, height: 70)
            .cornerRadius(Design.CornerRadius.button)

            // Info
            VStack(alignment: .leading, spacing: Design.Spacing.compact) {
                Text(entry.dish.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Design.Colors.primaryText)

                Text(entry.dish.cuisineName)
                    .font(.caption)
                    .foregroundColor(Design.Colors.secondaryText)

                Text(formattedDate(entry.timestamp))
                    .font(.caption2)
                    .foregroundColor(Design.Colors.secondaryText)
            }

            Spacer()

            // Result Badge
            resultBadge
        }
        .padding(Design.Spacing.standard)
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }

    @ViewBuilder
    private var resultBadge: some View {
        switch entry.liked {
        case 1:
            Label("喜欢", systemImage: "heart.fill")
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.12))
                )
        case -1:
            Label("跳过", systemImage: "xmark")
                .font(.caption)
                .foregroundColor(Design.Colors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Design.Colors.cardBackground)
                )
        default:
            EmptyView()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
