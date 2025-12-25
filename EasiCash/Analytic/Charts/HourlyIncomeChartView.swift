//
//  HourlyIncomeChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI
import Charts

struct HourlyIncomeChartView: View {
    var viewModel: SaleViewModel
    @State private var selectedHour: Int?

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.get24HourIncomeComparison()) { series in
                    ForEach(series.sales) { element in
                        LineMark(
                            x: .value("Hour", element.hour),
                            y: .value("Income", element.income)
                        )
                        .foregroundStyle(by: .value("Series", series.label))
                    }
                }

                if let selectedHour {
                    RuleMark(x: .value("Selected Hour", selectedHour))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .offset(yStart: -10)
                        .zIndex(-1)
                        .annotation(position: .top, alignment: .center) {
                            let todayIncome = viewModel
                                .get24HourIncomeComparison()[0]
                                .sales
                                .first(where: { $0.hour == selectedHour })?.income ?? 0

                            let yesterdayIncome = viewModel
                                .get24HourIncomeComparison()[1]
                                .sales
                                .first(where: { $0.hour == selectedHour })?.income ?? 0

                            VStack {
                                Text("Hour: \(selectedHour):00")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Today: $\(String(format: "%.2f", todayIncome))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Yesterday: $\(String(format: "%.2f", yesterdayIncome))")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(4)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(4)
                            .shadow(radius: 2)
                        }
                }
            }
            .chartForegroundStyleScale([
                "Today": Color.blue,
                "Yesterday": Color.orange
            ])
            .chartXScale(domain: 0...23) // Limit x-axis to 24 hours
            .chartXAxis {
                AxisMarks(values: Array(0...23)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartLegend(position: .bottom)
            .chartXSelection(value: $selectedHour)
            .frame(height: 300)
            .padding()

            Text("24-Hour Income Comparison")
                .font(.title2.bold())
                .gradientForeground(colors: [Color.blue, Color.orange])

        }
        .padding()
    }
}
