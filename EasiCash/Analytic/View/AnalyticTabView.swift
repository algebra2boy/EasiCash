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
            VStack(spacing: 20) {

                HStack(spacing: 20) {
                    revenueBox()

//                    BarChartView(viewModel: viewModel)
//                        .layoutPriority(1)
//                    
                    PieChartView(viewModel: viewModel)
                        .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding()

                HourlyIncomeChartView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()

            }
            .navigationTitle("Analytic")
            .padding(20)
        }
    }

    @ViewBuilder
    private func revenueBox() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.gray.opacity(0.15))
                .gradientForeground(colors: [Color.green, Color.yellow])
                .shadow(radius: 10)

            VStack {
                Text(String(format: "$%.2f", viewModel.getTodayRevenue()))
                    .font(.system(size: 50))
                    .foregroundStyle(Color.primary.opacity(0.9))

                Text("Today Total Revenue")
                    .font(.system(size: 25, weight: .bold))
                    .gradientForeground(colors: [Color.green, Color.yellow])
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 350)
        .layoutPriority(1)
    }
}

#Preview {
    AnalyticTabView()
        .environment(SaleViewModel.mock)
}
