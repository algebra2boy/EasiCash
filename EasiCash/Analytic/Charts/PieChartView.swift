//
//  PieChartView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI
import Charts

struct PieChartView: View {
    var viewModel: SaleViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 350, height: 350)
                .gradientForeground(colors: [Color.orange, Color.cyan])

            Chart(viewModel.getSalesByCategory()) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Category", item.category))
            }
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("Distribution of")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Items by Category")
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            .frame(width: 300, height: 300)
        }
    }

}
