//
//  PieChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Charts
import SwiftUI

struct PieChartView: View {
    var viewModel: SaleViewModel

    var body: some View {
        Chart(viewModel.getSalesByCategory()) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(8)
            .foregroundStyle(by: .value("Category", item.category))
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.saleHistory.count)")
                        .font(.headline.bold())
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
        .chartLegend(position: .bottom, spacing: 16)
        .padding()
    }
}
