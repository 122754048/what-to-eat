import SwiftUI

// MARK: - Diet Filter Sheet
struct DietFilterSheet: View {
    @Binding var selectedFilters: Set<DietFilter>
    @Environment(\.dismiss) var dismiss

    let onApply: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Design.Spacing.cardMargin) {
                    // Header
                    Text("选择忌口偏好")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Design.Colors.primaryText)
                        .padding(.horizontal, Design.Spacing.screenPadding)

                    Text("我们将根据您的选择过滤不适合的菜品")
                        .font(.subheadline)
                        .foregroundColor(Design.Colors.secondaryText)
                        .padding(.horizontal, Design.Spacing.screenPadding)

                    // Filter Groups
                    VStack(spacing: Design.Spacing.cardMargin) {
                        filterGroup(title: "过敏原", filters: DietFilter.allergens)
                        filterGroup(title: "饮食习惯", filters: DietFilter.dietary)
                        filterGroup(title: "口味偏好", filters: DietFilter.taste)
                    }
                    .padding(.horizontal, Design.Spacing.screenPadding)

                    // Selected Summary
                    if !selectedFilters.isEmpty {
                        selectedSummary
                    }
                }
                .padding(.vertical, Design.Spacing.screenPadding)
            }
            .background(Design.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("重置") {
                        selectedFilters.removeAll()
                    }
                    .foregroundColor(Design.Colors.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Design.Colors.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func filterGroup(title: String, filters: [DietFilter]) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.standard) {
            Text(title)
                .font(.headline)
                .foregroundColor(Design.Colors.primaryText)

            FlowLayout(spacing: Design.Spacing.standard) {
                ForEach(filters) { filter in
                    FilterChip(
                        filter: filter,
                        isSelected: selectedFilters.contains(filter)
                    ) {
                        toggleFilter(filter)
                    }
                }
            }
        }
    }

    private var selectedSummary: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.element) {
            Text("已选择 \(selectedFilters.count) 项")
                .font(.subheadline)
                .foregroundColor(Design.Colors.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.element) {
                    ForEach(Array(selectedFilters)) { filter in
                        HStack(spacing: Design.Spacing.compact) {
                            Text(filter.rawValue)
                                .font(.caption)
                                .foregroundColor(Design.Colors.primary)

                            Button {
                                selectedFilters.remove(filter)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                                    .foregroundColor(Design.Colors.primary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Design.Colors.primary.opacity(0.12))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Design.CornerRadius.card)
                .fill(Design.Colors.cardBackground)
        )
        .padding(.horizontal, Design.Spacing.screenPadding)
    }

    private func toggleFilter(_ filter: DietFilter) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let filter: DietFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Design.Spacing.compact) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : Design.Colors.primaryText)
            .padding(.horizontal, Design.Spacing.standard)
            .padding(.vertical, Design.Spacing.element)
            .background(
                Capsule()
                    .fill(isSelected ? Design.Colors.primary : Design.Colors.cardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Design.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Diet Filter Enum
enum DietFilter: String, CaseIterable, Identifiable, Codable {
    // Allergens
    case shellfish = "贝类过敏"
    case peanuts = "花生过敏"
    case gluten = "麸质过敏"
    case dairy = "乳糖不耐"
    case soy = "大豆过敏"

    // Dietary
    case vegetarian = "素食"
    case vegan = "纯素"
    case halal = "清真"
    case kosher = "犹太洁食"
    case lowCalorie = "低卡路里"

    // Taste
    case spicy = "不辣"
    case mild = "少盐"
    case noSeafood = "不吃海鲜"
    case noMeat = "不吃红肉"
    case noFried = "不油炸"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .shellfish: return "fish.fill"
        case .peanuts: return "leaf.fill"
        case .gluten: return "wheat.fill"
        case .dairy: return "drop.fill"
        case .soy: return "leaf.arrow.circlepath"
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .halal: return "checkmark.seal.fill"
        case .kosher: return "star.of.david.fill"
        case .lowCalorie: return "flame.fill"
        case .spicy: return "flame"
        case .mild: return "drop"
        case .noSeafood: return "fish"
        case .noMeat: return "fork.knife"
        case .noFried: return "circle.hexagongrid"
        }
    }

    static var allergens: [DietFilter] {
        [.shellfish, .peanuts, .gluten, .dairy, .soy]
    }

    static var dietary: [DietFilter] {
        [.vegetarian, .vegan, .halal, .kosher, .lowCalorie]
    }

    static var taste: [DietFilter] {
        [.spicy, .mild, .noSeafood, .noMeat, .noFried]
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            height = currentY + lineHeight
        }
    }
}
