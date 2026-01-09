//
//  CategoryComparisonChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 1/1/26.
//

import Charts
import SwiftUI

struct CategoryComparisonChartView: View {
    var viewModel: SaleViewModel

    var body: some View {
        let data = viewModel.getCategoryComparison()

        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Quantity", item.todayAmount)
                )
                .foregroundStyle(.blue)
                .position(by: .value("Day", "Today"))

                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Quantity", item.yesterdayAmount)
                )
                .foregroundStyle(.orange)
                .position(by: .value("Day", "Yesterday"))
            }
        }
        .chartForegroundStyleScale([
            "Today": Color.blue,
            "Yesterday": Color.orange,
        ])
        .chartLegend(position: .top)
        .frame(minHeight: 250)
    }
}
