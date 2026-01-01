//
//  SaleViewModel.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import Foundation
import SwiftUI

@Observable @MainActor class SaleViewModel {

    @ObservationIgnored
    private var dataSource: MenuDataSource?

    var saleHistory: [Order]

    init(saleHistory: [Order] = []) {
        self.dataSource = MenuDataSource.shared
        self.saleHistory = self.dataSource?.fetchOrders() ?? saleHistory
    }

    func getOverallSale() -> [BarchartSaleByAmount] {
        var foodCount: [String: Int] = [:]

        for order in saleHistory {
            for item in order.items {
                foodCount[item.title, default: 0] += item.quantity
            }
        }

        return foodCount.map { (foodName, count) in
            BarchartSaleByAmount(title: foodName, amount: count)
        }
        .sorted { $0.amount > $1.amount }
    }

    func getSalesByCategory() -> [PiechartSaleByCategory] {
        var categoryAmount: [String: Int] = [:]

        for order in saleHistory {
            for item in order.items {
                categoryAmount[item.category.rawValue, default: 0] += item.quantity
            }
        }

        return categoryAmount.map { (category, amount) in
            PiechartSaleByCategory(category: category, amount: amount)
        }
        .sorted { $0.amount > $1.amount }
    }

    func get24HourIncomeComparison() -> [HourlyIncomeSeries] {
        var hourlyIncomeToday = Array(repeating: 0.0, count: 24)
        var hourlyIncomeYesterday = Array(repeating: 0.0, count: 24)

        let calendar = Calendar.current

        for order in saleHistory {
            let components = calendar.dateComponents([.hour, .day], from: order.createdAt)

            if let hour = components.hour {
                if calendar.isDateInToday(order.createdAt) {
                    hourlyIncomeToday[hour] += order.price
                } else if calendar.isDateInYesterday(order.createdAt) {
                    hourlyIncomeYesterday[hour] += order.price
                }
            }
        }

        let todaySeries = HourlyIncomeSeries(
            label: "Today",
            sales: (0..<24).map { hour in
                HourlyIncomeElement(hour: hour, income: hourlyIncomeToday[hour])
            }
        )

        let yesterdaySeries = HourlyIncomeSeries(
            label: "Yesterday",
            sales: (0..<24).map { hour in
                HourlyIncomeElement(hour: hour, income: hourlyIncomeYesterday[hour])
            }
        )

        return [todaySeries, yesterdaySeries]
    }

    func getTodayRevenue() -> Double {
        saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }.reduce(0) {
            $0 + $1.price
        }
    }

    func getYesterdayRevenue() -> Double {
        saleHistory.filter { Calendar.current.isDateInYesterday($0.createdAt) }.reduce(0) {
            $0 + $1.price
        }
    }

    func getRevenueTrend() -> Double {
        let today = getTodayRevenue()
        let yesterday = getYesterdayRevenue()
        guard yesterday > 0 else { return 0 }
        return (today - yesterday) / yesterday
    }

    func getTopSellingProduct() -> (name: String, count: Int)? {
        let sales = getOverallSale()
        return sales.first.map { ($0.title, $0.amount) }
    }

    func getUnderperformingProducts() -> [String] {
        let sales = getOverallSale()
        return sales.filter { $0.amount < 5 }.map { $0.title }
    }

    func getPredictedRevenueNextWeek() -> Double {
        let last7DaysOrders = saleHistory.filter {
            $0.createdAt > Date().addingTimeInterval(-7 * 24 * 3600)
        }
        let averageDaily = last7DaysOrders.reduce(0) { $0 + $1.price } / 7.0
        return averageDaily * 1.1  // Predicting 10% growth for demo
    }

    func getInsights() -> [Insight] {
        var insights: [Insight] = []

        let trend = getRevenueTrend()
        if trend > 0.1 {
            insights.append(
                Insight(
                    title: "Strong Growth",
                    message: "Revenue is up \(Int(trend * 100))% from yesterday. Keep it up!",
                    systemImage: "arrow.up.right.circle.fill", color: .green))
        } else if trend < -0.1 {
            insights.append(
                Insight(
                    title: "Revenue Drop",
                    message:
                        "Sales are down \(Int(abs(trend) * 100))%. Consider a happy hour promotion.",
                    systemImage: "arrow.down.right.circle.fill", color: .red))
        }

        if let top = getTopSellingProduct() {
            insights.append(
                Insight(
                    title: "Popular Item",
                    message:
                        "\(top.name) is selling fast toay (\(top.count) orders). Stock up on ingredients!",
                    systemImage: "star.fill", color: .orange))
        }

        let slow = getUnderperformingProducts()
        if !slow.isEmpty {
            insights.append(
                Insight(
                    title: "Inventory Alert",
                    message: "Slow movers: \(slow.joined(separator: ", ")). Reduce next order.",
                    systemImage: "exclamationmark.triangle.fill", color: .yellow))
        }

        return insights
    }

    func addSale(
        with checkoutList: CheckOutList, name: String, note: String, type: OrderType,
        totalPrice: Double
    ) {
        let newOrder = Order(
            user: name, note: note, price: totalPrice, items: checkoutList.items, type: type)
        dataSource?.addOrder(newOrder)
        self.saleHistory.append(newOrder)
    }

    func refreshOrders() {
        self.saleHistory = dataSource?.fetchOrders() ?? []
    }

    func deleteOrder(_ order: Order) {
        dataSource?.deleteOrder(order)
        refreshOrders()
    }

    static var mock: SaleViewModel {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let mockOrders: [Order] = [
            // Today
            Order(
                user: "User 1", note: "", price: 45.0,
                items: [
                    MenuItem(
                        imageName: "burger", title: "Burger", category: .food, price: 15.0,
                        quantity: 3)
                ], createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                type: .inStore),
            Order(
                user: "User 2", note: "", price: 25.0,
                items: [
                    MenuItem(
                        imageName: "thaiTea", title: "Thai Tea", category: .drink, price: 5.0,
                        quantity: 5)
                ], createdAt: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: today)!,
                type: .online),
            Order(
                user: "User 3", note: "", price: 60.0,
                items: [
                    MenuItem(
                        imageName: "pho", title: "Pho", category: .food, price: 12.0, quantity: 5)
                ], createdAt: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!,
                type: .online),

            // Yesterday (Slower day)
            Order(
                user: "User 4", note: "", price: 30.0,
                items: [
                    MenuItem(
                        imageName: "burger", title: "Burger", category: .food, price: 15.0,
                        quantity: 2)
                ],
                createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),
            Order(
                user: "User 5", note: "", price: 15.0,
                items: [
                    MenuItem(
                        imageName: "thaiTea", title: "Thai Tea", category: .drink, price: 5.0,
                        quantity: 3)
                ],
                createdAt: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            // Two days ago (Busy day)
            Order(
                user: "User 6", note: "", price: 120.0,
                items: [
                    MenuItem(
                        imageName: "sushi", title: "Sushi", category: .food, price: 20.0,
                        quantity: 6)
                ],
                createdAt: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: twoDaysAgo)!,
                type: .online),
        ]

        return SaleViewModel(saleHistory: mockOrders)
    }
}
