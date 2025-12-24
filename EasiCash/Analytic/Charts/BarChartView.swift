//
//  BarChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var viewModel: SaleViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.gray.opacity(0.15))
                .gradientForeground(colors: [Color.green, Color.pink])
                .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)

            Chart(viewModel.getOverallSale()) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Title", item.title)
                )
                .annotation(position: .overlay) {
                    Text("\(item.amount)")
                        .font(.caption.bold())
                        .gradientForeground(colors: [Color.white])
                        .shadow(radius: 2)
                }
                .cornerRadius(5)
                .foregroundStyle(by: .value("Amount", item.amount > 50 ? "High" : "Low"))
            }
            .chartForegroundStyleScale([
                "High": Color.green.opacity(1),
                "Low": Color.red.opacity(1)
            ])
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom) {
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
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
