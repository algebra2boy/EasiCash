//
//  RevenueDetailView.swift
//  EasiCash
//
//  Created by CHENGTAO on 1/1/26.
//

import Charts
import SwiftUI

struct RevenueDetailView: View {
    var viewModel: SaleViewModel

    @State private var selectedSale: SaleViewModel.MockSale?

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                dailyInsightView
                salesTimelineView
                detailedBreakdownView
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Today's Performance")
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Subviews

    private var dailyInsightView: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.orange)
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Insight")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                if let top = viewModel.getTopSellingProduct() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(top.name)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                            + Text(" is your top seller today.")
                            .foregroundStyle(.secondary)

                        Text("Peak sales volume occurred around \(viewModel.getBestRevenueHour()).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                } else {
                    Text("No enough data for insights yet.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        .padding(.horizontal)
    }

    private var salesTimelineView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sales Timeline")
                    .font(.headline)
                Text("Hourly breakdown by product")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            timelineChart
        }
        .padding(.vertical, 24)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }

    private var timelineChart: some View {
        let chartData = getHourlyStackedData()
        let colorRange: [Color] = [
            Color.blue.opacity(0.8),
            Color.purple.opacity(0.8),
            Color.pink.opacity(0.8),
            Color.teal.opacity(0.8),
            Color.orange.opacity(0.8),
            Color.indigo.opacity(0.8),
        ]

        // Create today's 24-hour domain (start of today to start of tomorrow)
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday

        let baseChart = Chart(chartData) { item in
            BarMark(
                x: .value("Time", item.date, unit: .hour),
                y: .value("Orders", item.count)
            )
            .foregroundStyle(by: .value("Product", item.product))
            .cornerRadius(2)
        }
        .chartXScale(domain: startOfToday...endOfToday)

        let chartWithXAxis = baseChart.chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.hour())
            }
        }

        let chartWithYAxis = chartWithXAxis.chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisValueLabel()
            }
        }

        let chartWithColors = chartWithYAxis.chartForegroundStyleScale(range: colorRange)

        return
            chartWithColors
            .frame(height: 320)
            .padding(.horizontal)
    }

    private var detailedBreakdownView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Breakdown")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(viewModel.getDishesSoldToday()) { dish in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(dish.name)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(dish.quantity) orders")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "$%.2f", dish.revenue))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)

                    if dish.id != viewModel.getDishesSoldToday().last?.id {
                        Divider().padding(.leading)
                    }
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers

    private func getHourlyStackedData() -> [HourlyStackItem] {
        let sales = viewModel.getTodaySales()
        let calendar = Calendar.current

        // Group by hour
        var buckets: [Date: [String: Int]] = [:]

        for sale in sales {
            // Normalize to start of hour
            let hourDate =
                calendar.date(
                    bySettingHour: calendar.component(.hour, from: sale.createdAt),
                    minute: 0,
                    second: 0,
                    of: sale.createdAt
                ) ?? sale.createdAt

            var productCounts = buckets[hourDate] ?? [:]
            productCounts[sale.productName, default: 0] += 1
            buckets[hourDate] = productCounts
        }

        var result: [HourlyStackItem] = []
        for (date, counts) in buckets {
            for (product, count) in counts {
                result.append(HourlyStackItem(date: date, product: product, count: count))
            }
        }
        return result.sorted { $0.date < $1.date }
    }
}

struct HourlyStackItem: Identifiable {
    let id = UUID()
    let date: Date
    let product: String
    let count: Int
}
