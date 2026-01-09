//
//  RevenueComparisonChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 1/1/26.
//

import Charts
import SwiftUI

enum DateRangePreset: String, CaseIterable {
    case today = "Today"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case custom = "Custom Range"
}

struct RevenueComparisonChartView: View {
    var viewModel: SaleViewModel
    var initialPreset: DateRangePreset = .last7Days

    @State private var selectedPreset: DateRangePreset

    init(viewModel: SaleViewModel, initialPreset: DateRangePreset = .last7Days) {
        self.viewModel = viewModel
        self.initialPreset = initialPreset
        _selectedPreset = State(initialValue: initialPreset)

        // Initialize dates based on preset
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var start = today

        switch initialPreset {
        case .today:
            start = today
        case .last7Days:
            start = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        case .last30Days:
            start = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        case .custom:
            start = today  // Default
        }

        _primaryStartDate = State(initialValue: start)
        _primaryEndDate = State(initialValue: today)
    }
    @State private var primaryStartDate: Date
    @State private var primaryEndDate: Date
    @State private var showDatePicker = false
    @State private var selectedDate: Date?
    @State private var selectedHour: Int?

    private let calendar = Calendar.current

    // Theme Colors
    private let themeBlue = Color(red: 0.1, green: 0.45, blue: 0.9)  // Deep professional blue

    private var isTodayMode: Bool {
        calendar.isDate(primaryStartDate, inSameDayAs: Date())
            && calendar.isDate(primaryEndDate, inSameDayAs: Date())
    }

    var body: some View {
        VStack(spacing: 20) {

            // 1. Controls (Filters)
            controlsView

            // 2. Main Chart Card (Visuals + Stats)
            VStack(spacing: 0) {

                // Chart Internal Header (Period Stats)
                // We moved "Global Pulse" to the parent view, so these are strict "Period Stats"
                periodStatsRow
                    .padding()
                    .background(Color.white.opacity(0.1))

                Divider().overlay(Color.white.opacity(0.2))

                // The Graph
                chartArea
                    .padding(24)
            }
            .background(themeBlue.gradient)
            .cornerRadius(24)
            .shadow(color: themeBlue.opacity(0.3), radius: 15, x: 0, y: 10)
        }
    }

    // MARK: - Subviews

    private var controlsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preset Pills
            AnalyticTab(
                items: DateRangePreset.allCases,
                selected: $selectedPreset,
                title: { $0.rawValue }
            )
            .onChange(of: selectedPreset) { _, newValue in
                updateDatesForPreset(newValue)
            }

            // Date Range (Visible for Custom or for context)
            if selectedPreset == .custom {
                HStack(spacing: 8) {
                    Label("Date Range:", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    DatePicker("", selection: $primaryStartDate, displayedComponents: [.date])
                        .labelsHidden()
                    Text("-")
                    DatePicker(
                        "", selection: $primaryEndDate, in: primaryStartDate...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }
                .transition(.opacity.combined(with: .slide))
                .padding(.horizontal)
            }
        }
    }

    private var periodStatsRow: some View {
        let metrics = isTodayMode ? calculateHourlyMetrics() : calculateMetrics()

        return HStack(spacing: 24) {
            // Total for Period
            VStack(alignment: .leading) {
                Text("Period Revenue")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .textCase(.uppercase)

                Text(formatCurrency(metrics.totalRevenue))
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            Divider().overlay(Color.white.opacity(0.3)).frame(height: 30)

            // Peak Time/Day
            VStack(alignment: .leading) {
                Text(isTodayMode ? "Peak Hour" : "Best Day")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .textCase(.uppercase)

                Text(
                    isTodayMode
                        ? formatHour(Int(metrics.peakDayRevenue))
                        : formatCurrency(metrics.peakDayRevenue)
                )
                .font(.title2.bold())
                .foregroundStyle(.white)
            }

            Spacer()

            // Context/Trend
            if !isTodayMode {
                VStack(alignment: .trailing) {
                    Text("vs Previous")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .textCase(.uppercase)

                    HStack(spacing: 4) {
                        Image(systemName: metrics.revenueChange >= 0 ? "arrow.up" : "arrow.down")
                        Text(formatPercentage(Double(abs(metrics.revenueChange))))
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(
                        metrics.revenueChange >= 0
                            ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
                    )  // Softer colors on blue
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private var chartArea: some View {
        if isTodayMode {
            hourlyChartView
        } else {
            dailyChartView
        }
    }

    private var dailyChartView: some View {
        let primaryData = getRevenueDataForRange(from: primaryStartDate, to: primaryEndDate)

        return Chart {
            ForEach(primaryData) { data in
                // Gradient Fill
                AreaMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Revenue", data.revenue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                // Line
                LineMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Revenue", data.revenue)
                )
                .foregroundStyle(.white)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }

            // Interactive Selection
            if let selectedDate = selectedDate {
                RuleMark(x: .value("Date", selectedDate, unit: .day))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top) {
                        selectionPopup(for: selectedDate, primaryData: primaryData)
                    }

                if let match = primaryData.first(where: {
                    calendar.isDate($0.date, inSameDayAs: selectedDate)
                }) {
                    PointMark(
                        x: .value("Date", match.date, unit: .day),
                        y: .value("Revenue", match.revenue)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(100)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: calculateXAxisStride())) { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.1))
                AxisValueLabel(format: .dateTime.month().day())
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine().foregroundStyle(.white.opacity(0.1))
                AxisValueLabel().foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 250)
        .chartXSelection(value: $selectedDate)
    }

    private var hourlyChartView: some View {
        // Fix: Use data safely. Ensure we display something even if 0.
        // We use the 'Today' series from the comparison data
        let hourlyData =
            viewModel.get24HourIncomeComparison().first(where: { $0.label == "Today" })?.sales ?? []

        return Chart {
            ForEach(hourlyData) { data in
                BarMark(
                    x: .value("Hour", data.hour),
                    y: .value("Income", data.income)
                )
                .foregroundStyle(.white.opacity(0.6))
                .cornerRadius(4)

                // Add a line on top to see the trend clearer
                LineMark(
                    x: .value("Hour", data.hour),
                    y: .value("Income", data.income)
                )
                .foregroundStyle(.white)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }

            if let selectedHour {
                RuleMark(x: .value("Hour", selectedHour))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .top) {
                        hourlySelectionPopup(for: selectedHour, data: hourlyData)
                    }
            }
        }
        .chartXScale(domain: 8...22)  // Optimize domain to show business hours typically (8am - 10pm) or full Day
        // Using full day but with stride
        .chartXAxis {
            AxisMarks(values: .stride(by: 4)) { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.1))
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text("\(hour):00").foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine().foregroundStyle(.white.opacity(0.1))
                AxisValueLabel().foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 250)
        .chartXSelection(value: $selectedHour)
    }

    // MARK: - Helper Methods

    private func updateDatesForPreset(_ preset: DateRangePreset) {
        let today = calendar.startOfDay(for: Date())

        switch preset {
        case .today:
            primaryStartDate = today
            primaryEndDate = today
        case .last7Days:
            primaryStartDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            primaryEndDate = today
        case .last30Days:
            primaryStartDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
            primaryEndDate = today
        case .custom:
            showDatePicker = true
        }
    }

    private func getRevenueDataForRange(from startDate: Date, to endDate: Date) -> [DailyRevenue] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        var revenueByDate: [Date: Double] = [:]

        for order in viewModel.saleHistory {
            let orderDate = calendar.startOfDay(for: order.createdAt)
            if orderDate >= start && orderDate <= end {
                revenueByDate[orderDate, default: 0] += order.price
            }
        }

        // Fill in missing dates
        var data: [DailyRevenue] = []
        var currentDate = start
        while currentDate <= end {
            data.append(DailyRevenue(date: currentDate, revenue: revenueByDate[currentDate] ?? 0))
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }
        return data
    }

    private func calculateMetrics() -> RevenueMetrics {
        let data = getRevenueDataForRange(from: primaryStartDate, to: primaryEndDate)
        let total = data.reduce(0) { $0 + $1.revenue }
        let peak = data.map { $0.revenue }.max() ?? 0

        // Change logic
        let days = max(
            1, calendar.dateComponents([.day], from: primaryStartDate, to: primaryEndDate).day ?? 1)
        let prevEnd =
            calendar.date(byAdding: .day, value: -1, to: primaryStartDate) ?? primaryStartDate
        let prevStart = calendar.date(byAdding: .day, value: -days, to: prevEnd) ?? prevEnd
        let prevData = getRevenueDataForRange(from: prevStart, to: prevEnd)
        let prevTotal = prevData.reduce(0) { $0 + $1.revenue }

        let change = prevTotal > 0 ? (total - prevTotal) / prevTotal : 0

        return RevenueMetrics(
            totalRevenue: total, averageDailyRevenue: 0, revenueChange: change, peakDayRevenue: peak
        )
    }

    private func calculateHourlyMetrics() -> RevenueMetrics {
        let hourlyData =
            viewModel.get24HourIncomeComparison().first(where: { $0.label == "Today" })?.sales ?? []
        let total = hourlyData.reduce(0) { $0 + $1.income }
        let peakHour = hourlyData.max(by: { $0.income < $1.income })?.hour ?? 12

        // Mock trend for today (vs yesterday same time)
        let trend = viewModel.getRevenueTrend()

        return RevenueMetrics(
            totalRevenue: total, averageDailyRevenue: 0, revenueChange: trend,
            peakDayRevenue: Double(peakHour))
    }

    private func calculateXAxisStride() -> Int {
        let days =
            calendar.dateComponents([.day], from: primaryStartDate, to: primaryEndDate).day ?? 1
        return days <= 7 ? 1 : (days <= 30 ? 7 : 14)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    private func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "0%"
    }

    private func formatHour(_ hour: Int) -> String {
        let date =
            Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    // Popups
    @ViewBuilder
    private func selectionPopup(for date: Date, primaryData: [DailyRevenue]) -> some View {
        let val =
            primaryData.first(where: { calendar.isDate($0.date, inSameDayAs: date) })?.revenue ?? 0
        VStack {
            Text(date, format: .dateTime.month().day())
                .font(.caption2.bold())
            Text(formatCurrency(val))
                .font(.caption.bold())
        }
        .padding(8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }

    @ViewBuilder
    private func hourlySelectionPopup(for hour: Int, data: [HourlyIncomeElement])
        -> some View
    {
        let val = data.first(where: { $0.hour == hour })?.income ?? 0
        VStack {
            Text(formatHour(hour))
                .font(.caption2.bold())
            Text(formatCurrency(val))
                .font(.caption.bold())
        }
        .padding(8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

// MARK: - Supporting Types

struct DailyRevenue: Identifiable {
    let id = UUID()
    let date: Date
    let revenue: Double
}

struct RevenueMetrics {
    let totalRevenue: Double
    let averageDailyRevenue: Double
    let revenueChange: Double
    let peakDayRevenue: Double
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    RevenueComparisonChartView(viewModel: .mock)
        .padding()
}
