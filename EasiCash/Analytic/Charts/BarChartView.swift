//
//  BarChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Charts
import SwiftUI

struct BarChartView: View {
    var viewModel: SaleViewModel

    var body: some View {
        Chart(viewModel.getOverallSale()) { item in
            BarMark(
                x: .value("Amount", item.amount),
                y: .value("Title", item.title)
            )
            .cornerRadius(6)
            .foregroundStyle(item.amount > 5 ? Color.blue.gradient : Color.gray.gradient)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom)
        }
        .chartYAxis {
            AxisMarks(preset: .aligned, position: .leading)
        }
        .padding()
    }
}
