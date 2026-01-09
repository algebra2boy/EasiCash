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
                VStack(spacing: 32) {
                    // 1. Header & Greeting
                    headerSection
                        .padding(.top, 8)

                    // 2. Business Pulse (The "Now" State)
                    // High-level KPIs that answer "How are we doing right now?"
                    pulseSection

                    // 3. Revenue Analytics (The "Trend" State)
                    // Deep dive into performance over time
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Revenue Trends")
                            .font(.title3.bold())
                            .padding(.horizontal)

                        RevenueComparisonChartView(viewModel: viewModel)
                            .padding(.horizontal)
                    }

                    // 4. Actionable Insights
                    // "What should I do?"
                    // VStack(alignment: .leading, spacing: 16) {
                    //     HStack {
                    //         Image(systemName: "lightbulb.fill")
                    //             .foregroundStyle(.yellow)
                    //         Text("Smart Insights")
                    //             .font(.title3.bold())
                    //     }
                    //     .padding(.horizontal)

                    //     InsightSuggestionView(insights: viewModel.getInsights())
                    //         .padding(.horizontal)
                    // }

                    Spacer(minLength: 60)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "Revenue":
                    RevenueDetailView(viewModel: viewModel)
                case "TopProduct":
                    TopProductDetailView(viewModel: viewModel)
                case "ActiveOrders":
                    ActiveOrdersDetailView(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date(), format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text("Good Evening, Owner")
                    .font(.largeTitle.bold())
            }

            Spacer()

            Button {
                viewModel.refreshOrders()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }

    private var pulseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Business Pulse")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {

                // Card 1: Today's Revenue (The most critical metric)
                NavigationLink(value: "Revenue") {
                    PulseCard(
                        title: "Today's Revenue",
                        value: formatCurrency(viewModel.getTodayRevenue()),
                        trend: viewModel.getRevenueTrend(),
                        icon: "dollarsign.circle.fill",
                        color: .green,
                        isInteractive: true
                    )
                }
                .buttonStyle(.plain)

                // Card 2: Active Orders (Operational load)
                NavigationLink(value: "ActiveOrders") {
                    PulseCard(
                        title: "Active Orders",
                        value: "\(viewModel.getActiveOrders().count)",
                        trend: nil,
                        icon: "bag.fill",
                        color: .blue,
                        isInteractive: true
                    )
                }
                .buttonStyle(.plain)

                // Card 3: Top Item (What's hot)
                if let top = viewModel.getTopSellingProduct() {
                    NavigationLink(value: "TopProduct") {
                        PulseCard(
                            title: "Top Item: \(top.count) orders",
                            value: top.name,
                            // subValue: "\(top.count) orders",
                            trend: nil,
                            icon: "star.fill",
                            color: .orange,
                            isInteractive: true
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    PulseCard(
                        title: "Top Item",
                        value: "--",
                        trend: nil,
                        icon: "star.fill",
                        color: .gray,
                        isInteractive: false
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Supporting Views

struct PulseCard: View {
    let title: String
    let value: String
    var subValue: String? = nil
    let trend: Double?
    let icon: String
    let color: Color
    var isInteractive: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .padding(8)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Spacer()

                if isInteractive {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                }

                if let trend = trend {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(Int(abs(trend * 100)))%")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(trend >= 0 ? .green : .red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(trend >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    )
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)

                Text(value)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if let subValue {
                    Text(subValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isInteractive ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    AnalyticTabView()
        .environment(SaleViewModel.mock)
}
