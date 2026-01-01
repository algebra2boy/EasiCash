//
//  HourlyIncomeChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Charts
import SwiftUI

struct HourlyIncomeChartView: View {
    var viewModel: SaleViewModel
    @State private var selectedHour: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Chart {
                ForEach(viewModel.get24HourIncomeComparison()) { series in
                    ForEach(series.sales) { element in
                        AreaMark(
                            x: .value("Hour", element.hour),
                            y: .value("Income", element.income)
                        )
                        .foregroundStyle(by: .value("Series", series.label))
                        .interpolationMethod(.catmullRom)
                        .opacity(0.1)

                        LineMark(
                            x: .value("Hour", element.hour),
                            y: .value("Income", element.income)
                        )
                        .foregroundStyle(by: .value("Series", series.label))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                }

                if let selectedHour {
                    RuleMark(x: .value("Hour", selectedHour))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .annotation(position: .top) {
                            selectionPopup(for: selectedHour)
                        }
                }
            }
            .chartForegroundStyleScale([
                "Today": Color.blue,
                "Yesterday": Color.orange,
            ])
            .chartXScale(domain: 0...23)
            .chartXAxis {
                AxisMarks(values: .stride(by: 4))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXSelection(value: $selectedHour)
            .frame(height: 200)
        }
    }

    @ViewBuilder
    private func selectionPopup(for hour: Int) -> some View {
        let comparisons = viewModel.get24HourIncomeComparison()
        let todayIncome = comparisons[0].sales.first(where: { $0.hour == hour })?.income ?? 0
        let yesterdayIncome = comparisons[1].sales.first(where: { $0.hour == hour })?.income ?? 0

        VStack(alignment: .leading, spacing: 4) {
            Text("\(hour):00")
                .font(.caption.bold())
            HStack {
                Circle().fill(.blue).frame(width: 8, height: 8)
                Text("Today: $\(String(format: "%.2f", todayIncome))")
            }
            HStack {
                Circle().fill(.orange).frame(width: 8, height: 8)
                Text("Yesterday: $\(String(format: "%.2f", yesterdayIncome))")
            }
        }
        .font(.caption2)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
