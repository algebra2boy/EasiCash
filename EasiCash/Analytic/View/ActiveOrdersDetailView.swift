//
//  ActiveOrdersDetailView.swift
//  EasiCash
//
//  Created by CHENGTAO on 1/1/26.
//

import SwiftUI

struct ActiveOrdersDetailView: View {
    var viewModel: SaleViewModel
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var now = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Stats
                HStack(spacing: 16) {
                    StatCard(
                        title: "Active Orders", value: "\(viewModel.getActiveOrders().count)",
                        color: .blue)
                    StatCard(title: "Avg Prep Time", value: "12m", color: .orange)
                }

                Text("Kitchen Queue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getActiveOrders()) { activeOrder in
                        ActiveOrderRow(activeOrder: activeOrder, now: now)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Active Orders")
        .background(Color(uiColor: .systemGroupedBackground))
        .onReceive(timer) { input in
            now = input
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ActiveOrderRow: View {
    let activeOrder: SaleViewModel.ActiveOrderWrapper
    let now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order #\(activeOrder.originalOrder.id.uuidString.prefix(4))")
                    .font(.headline)
                    .monospacedDigit()

                Text(
                    "\(activeOrder.originalOrder.items.count) items • \(activeOrder.originalOrder.user)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(activeOrder.status.rawValue)
                    .font(.xs)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(activeOrder.status.color.opacity(0.2))
                    .foregroundStyle(activeOrder.status.color)
                    .cornerRadius(8)

                let diff = max(0, now.timeIntervalSince(activeOrder.originalOrder.createdAt))  // Mocking start time as createdAt
                // Since createdAt in mock data is fixed, this might show large numbers.
                // In a real app we'd use relative time.
                // For this mock, we used "now" in ActiveOrders implementation so it shouldn't be too old if generated fresh,
                // but saleHistory mock data has hardcoded dates.
                // Let's just Format it nicely.

                Text(formatDuration(activeOrder.timeElapsed))  // Use the mock elapsed
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
    }

    func formatDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "00:00"
    }
}

extension Font {
    static let xs = Font.system(size: 10)
}
