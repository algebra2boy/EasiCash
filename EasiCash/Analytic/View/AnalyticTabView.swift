//
//  AnalyticTabView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import Charts
import SwiftUI

struct AnalyticTabView: View {

    @Environment(SaleViewModel.self) var viewModel: SaleViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Section
                    headerSection

                    summaryCardsSection

                    // Actionable Insights
                    InsightSuggestionView(insights: viewModel.getInsights())

                    // Data Visualizations
                    chartsSection
                }
                .padding()
            }
            .navigationTitle("Business Analytics")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning, Owner")
                    .font(.title2.bold())
                Text("Here's how your restaurant is doing today.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Button {
                viewModel.refreshOrders()
            } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
    }

    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            AnalyticSummaryCard(
                title: "Today's Revenue",
                value: String(format: "$%.2f", viewModel.getTodayRevenue()),
                trend: viewModel.getRevenueTrend(),
                systemImage: "dollarsign.circle.fill",
                color: .green
            )

            AnalyticSummaryCard(
                title: "Next Week Prediction",
                value: String(format: "$%.0f", viewModel.getPredictedRevenueNextWeek()),
                trend: 0.1,  // Mock trend
                systemImage: "chart.line.uptrend.xyaxis",
                color: .purple
            )

            if let top = viewModel.getTopSellingProduct() {
                AnalyticSummaryCard(
                    title: "Top Product",
                    value: top.name,
                    trend: nil,
                    systemImage: "star.fill",
                    color: .orange
                )
            }

            AnalyticSummaryCard(
                title: "Active Orders",
                value:
                    "\(viewModel.saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }.count)",
                trend: nil,
                systemImage: "bag.fill",
                color: .blue
            )
        }
        .padding(.horizontal)
    }

    private var chartsSection: some View {
        VStack(spacing: 20) {
            ChartCard(title: "Sales Trends") {
                HourlyIncomeChartView(viewModel: viewModel)
            }

            HStack(spacing: 20) {
                ChartCard(title: "Category Distribution") {
                    PieChartView(viewModel: viewModel)
                }

                ChartCard(title: "Dish Popularity") {
                    BarChartView(viewModel: viewModel)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
                .frame(minHeight: 250)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
    }
}

#Preview {
    AnalyticTabView()
        .environment(SaleViewModel.mock)
}
