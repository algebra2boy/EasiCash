//
//  TopProductDetailView.swift
//  EasiCash
//
//  Created by CHENGTAO on 1/1/26.
//

import Charts
import SwiftUI

enum TimePeriodFilter: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
}

struct TopProductDetailView: View {
    var viewModel: SaleViewModel

    @State private var selectedFilter: TimePeriodFilter = .today

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // 1. Hero Block with Title
                VStack(alignment: .leading, spacing: 8) {
                    Text(
                        "Products ranked by total order volume \(selectedFilter.rawValue.lowercased())."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)

                // 2. Horizontal Bar Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Volume Analysis")
                        .font(.headline)
                        .padding(.horizontal)

                    Chart {
                        let filteredData = getFilteredSales().prefix(5).reversed()
                        let maxAmount = Double(
                            filteredData.max(by: { $0.amount < $1.amount })?.amount ?? 1)

                        ForEach(Array(filteredData)) { sale in
                            BarMark(
                                x: .value("Orders", sale.amount),
                                y: .value("Product", sale.title)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(
                                            0.4 + (Double(sale.amount) / maxAmount) * 0.6),
                                        Color.blue.opacity(
                                            0.1 + (Double(sale.amount) / maxAmount) * 0.9),
                                    ],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )
                            )
                            .cornerRadius(4)
                            .annotation(position: .trailing, alignment: .leading) {
                                Text("\(sale.amount)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(.caption.bold())
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }

                // 3. Leaderboard List
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Leaderboard")
                            .font(.headline)

                        // Filter Picker
                        Picker("Time Period", selection: $selectedFilter) {
                            ForEach(TimePeriodFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        let filteredSales = getFilteredSales()
                        ForEach(Array(filteredSales.enumerated()), id: \.element.id) {
                            index, sale in
                            RankRow(rank: index + 1, title: sale.title, count: sale.amount)

                            if index < filteredSales.count - 1 {
                                Divider().padding(.leading, 50)
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Top Products")
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Helpers

    private func getFilteredSales() -> [BarchartSaleByAmount] {
        let calendar = Calendar.current
        let now = Date()

        let startDate: Date
        switch selectedFilter {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .thisWeek:
            startDate =
                calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
                ?? now
        case .thisMonth:
            startDate =
                calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        case .thisYear:
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        }

        let filteredOrders = viewModel.saleHistory.filter { order in
            order.createdAt >= startDate && order.createdAt <= now
        }

        var foodCount: [String: Int] = [:]

        for order in filteredOrders {
            for item in order.items {
                foodCount[item.title, default: 0] += item.quantity
            }
        }

        return foodCount.map { (foodName, count) in
            BarchartSaleByAmount(title: foodName, amount: count)
        }
        .sorted { $0.amount > $1.amount }
    }
}

// MARK: - Subviews

struct RankRow: View {
    let rank: Int
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: 16) {
            // Rank Icon/Number
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor(for: rank).opacity(0.15))
                        .frame(width: 40, height: 40)

                    Text(rankEmoji(for: rank))
                        .font(.title2)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 40)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                // Optional: You could add revenue info here if available in the model
            }

            Spacer()

            // Value
            Text("\(count) orders")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(Capsule())
        }
        .padding()
    }

    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }

    private func rankEmoji(for rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}
