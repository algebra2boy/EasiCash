//
//  BarchartSaleByAmount.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import Foundation
import SwiftUI

struct BarchartSaleByAmount: Identifiable {
    let id = UUID()
    let title: String
    let amount: Int
}

struct PiechartSaleByCategory: Identifiable {
    let id = UUID()
    let category: String
    let amount: Int
}

struct HourlyIncomeSeries: Identifiable {
    let id = UUID()
    let label: String
    let sales: [HourlyIncomeElement]
}

struct HourlyIncomeElement: Identifiable {
    let id = UUID()
    let hour: Int
    let income: Double
}

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
    let color: SwiftUI.Color
}
