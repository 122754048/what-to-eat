import SwiftUI

// MARK: - History Page (Standalone Entry Point)
struct HistoryPage: View {
    var body: some View {
        VStack(spacing: 0) {
            // Unified Nav Bar
            HStack {
                Text("History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1A1A1A"))

                Spacer()

                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(Design.Colors.primary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Content
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        // Placeholder - actual content uses HistoryManager.shared
                        if HistoryManager.shared.entries.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(HistoryManager.shared.entries) { entry in
                                HistoryRow(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Design.Colors.background)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(Design.Colors.secondaryText.opacity(0.4))

            Text("No history yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#1A1A1A"))

            Text("Start swiping to discover dishes")
                .font(.subheadline)
                .foregroundColor(Color(hex: "#86868B"))

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    HistoryPage()
}
