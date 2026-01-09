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
        // Create detached copies of menu items to prevent SwiftData from inserting them as new menu entities
        // This fixes the bug where cart items would appear as duplicates in the menu after checkout
        let itemCopies = checkoutList.items.map { item in
            MenuItem(
                id: UUID(),
                imageName: item.imageName,
                image: item.image,
                title: item.title,
                category: item.category,
                price: item.price,
                quantity: item.quantity
            )
        }
        
        let newOrder = Order(
            user: name, note: note, price: totalPrice, items: itemCopies, type: type)
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

    // MARK: - Analytics Helpers

    struct DishSoldToday: Identifiable {
        let id = UUID()
        let name: String
        let quantity: Int
        let revenue: Double
    }

    struct MockSale: Identifiable {
        let id = UUID()
        let createdAt: Date
        let productName: String
        let price: Double
    }

    func getTodaySales() -> [MockSale] {
        let todayOrders = saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }
        var result: [MockSale] = []

        for order in todayOrders {
            for item in order.items {
                // For each quantity, we could theoretically add a dot.
                // To keep it simple, we'll add one entry per item instance in the order.
                for _ in 0..<item.quantity {
                    // Small fuzziness to time so dots don't perfectly overlap if same order
                    let fuzzyTime = order.createdAt.addingTimeInterval(Double.random(in: -60...60))
                    result.append(
                        MockSale(createdAt: fuzzyTime, productName: item.title, price: item.price))
                }
            }
        }
        return result.sorted { $0.createdAt < $1.createdAt }
    }

    func getDishesSoldToday() -> [DishSoldToday] {
        let todayOrders = saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }
        var dishMap: [String: (qty: Int, rev: Double)] = [:]

        for order in todayOrders {
            for item in order.items {
                let current = dishMap[item.title] ?? (qty: 0, rev: 0.0)
                dishMap[item.title] = (
                    qty: current.qty + item.quantity,
                    rev: current.rev + (item.price * Double(item.quantity))
                )
            }
        }

        return dishMap.map { key, value in
            DishSoldToday(name: key, quantity: value.qty, revenue: value.rev)
        }
        .sorted { $0.revenue > $1.revenue }
    }

    func getBestRevenueHour() -> String {
        let todayOrders = saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }
        var hourlyRevenue = Array(repeating: 0.0, count: 24)
        let calendar = Calendar.current

        for order in todayOrders {
            let hour = calendar.component(.hour, from: order.createdAt)
            hourlyRevenue[hour] += order.price
        }

        if let maxHour = hourlyRevenue.indices.max(by: { hourlyRevenue[$0] < hourlyRevenue[$1] }),
            hourlyRevenue[maxHour] > 0
        {
            // Format time, e.g., "1 PM - 2 PM" or "13:00 - 14:00"
            // Simple approach:
            let start = maxHour
            let end = (maxHour + 1) % 24
            return "\(start):00 - \(end):00"
        }
        return "N/A"
    }

    enum AnalyticsOrderStatus: String, CaseIterable {
        case preparing = "Preparing"
        case ready = "Ready"
        case delayed = "Delayed"

        var color: Color {
            switch self {
            case .preparing: return .orange
            case .ready: return .green
            case .delayed: return .red
            }
        }
    }

    struct ActiveOrderWrapper: Identifiable {
        let id = UUID()
        let originalOrder: Order
        let status: AnalyticsOrderStatus
        let timeElapsed: TimeInterval
    }

    func getActiveOrders() -> [ActiveOrderWrapper] {
        // Mock implementation since we don't have real "active" status
        // We'll consider today's orders as candidates and assign random statuses
        let todayOrders = saleHistory.filter { Calendar.current.isDateInToday($0.createdAt) }

        return todayOrders.prefix(5).map { order in
            // Mock status based on order hash or random
            let statuses = AnalyticsOrderStatus.allCases
            let status = statuses[Int.random(in: 0..<statuses.count)]
            let elapsed = Date().timeIntervalSince(order.createdAt)
            return ActiveOrderWrapper(originalOrder: order, status: status, timeElapsed: elapsed)
        }
    }

    struct CategoryComparisonData: Identifiable {
        let id = UUID()
        let category: String
        let todayAmount: Int
        let yesterdayAmount: Int
    }

    func getCategoryComparison() -> [CategoryComparisonData] {
        var todayMap: [String: Int] = [:]
        var yesterdayMap: [String: Int] = [:]

        let calendar = Calendar.current

        for order in saleHistory {
            if calendar.isDateInToday(order.createdAt) {
                for item in order.items {
                    todayMap[item.category.rawValue, default: 0] += item.quantity
                }
            } else if calendar.isDateInYesterday(order.createdAt) {
                for item in order.items {
                    yesterdayMap[item.category.rawValue, default: 0] += item.quantity
                }
            }
        }

        let allCategories = Set(todayMap.keys).union(yesterdayMap.keys)
        return allCategories.map { cat in
            CategoryComparisonData(
                category: cat,
                todayAmount: todayMap[cat] ?? 0,
                yesterdayAmount: yesterdayMap[cat] ?? 0
            )
        }
    }

    static var mock: SaleViewModel {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        return SaleViewModel(saleHistory: [
            // Orders for Today
            Order(
                id: UUID(), user: "Alice", note: "First order today", price: 15.98,
                items: [
                    MenuItem(
                        imageName: "burger", title: "burger", category: .food, price: 9.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99,
                        quantity: 1),
                ], createdAt: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Bob", note: "Great service!", price: 19.98,
                items: [
                    MenuItem(
                        imageName: "burger", title: "burger", category: .food, price: 9.99,
                        quantity: 2)
                ], createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                type: .online),

            Order(
                id: UUID(), user: "Charlie", note: "Quick delivery", price: 25.97,
                items: [
                    MenuItem(
                        imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 2)
                ], createdAt: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!,
                type: .online),

            Order(
                id: UUID(), user: "Eve", note: "Tasty!", price: 25.97,
                items: [
                    MenuItem(
                        imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 2)
                ], createdAt: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)!,
                type: .online),
            // Orders for Today
            Order(
                id: UUID(), user: "Aldvce", note: "First order today", price: 20.97,
                items: [
                    MenuItem(
                        imageName: "burger", title: "burger", category: .food, price: 9.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 3.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "cake", title: "cake", category: .dessert, price: 6.99,
                        quantity: 1),
                ], createdAt: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Boe", note: "Great service!", price: 28.98,
                items: [
                    MenuItem(
                        imageName: "pizza", title: "Pizza", category: .food, price: 14.99,
                        quantity: 2)
                ], createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                type: .online),

            Order(
                id: UUID(), user: "Charliest", note: "Quick delivery", price: 39.96,
                items: [
                    MenuItem(
                        imageName: "sushi", title: "Sushi", category: .food, price: 13.99,
                        quantity: 2),
                    MenuItem(
                        imageName: "noodle", title: "Noodle", category: .food, price: 9.99,
                        quantity: 1),
                ], createdAt: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!,
                type: .online),

            Order(
                id: UUID(), user: "Exve", note: "Tasty!", price: 30.97,
                items: [
                    MenuItem(
                        imageName: "pho", title: "Pho", category: .food, price: 12.99, quantity: 2),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 4.99,
                        quantity: 1),
                ], createdAt: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)!,
                type: .online),

            // Orders for Yesterday
            Order(
                id: UUID(), user: "Frank", note: "Will order again", price: 9.99,
                items: [
                    MenuItem(
                        imageName: "burger", title: "burger", category: .food, price: 9.99,
                        quantity: 1)
                ],
                createdAt: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Grace", note: "Loved the ambiance", price: 15.98,
                items: [
                    MenuItem(
                        imageName: "burger", title: "burger", category: .food, price: 9.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Hugo", note: "Thanks!", price: 19.98,
                items: [
                    MenuItem(
                        imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 6.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: yesterday)!,
                type: .online),

            Order(
                id: UUID(), user: "Ivy", note: "Quick and easy", price: 19.98,
                items: [
                    MenuItem(
                        imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 6.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Fransk", note: "Will order again", price: 18.98,
                items: [
                    MenuItem(
                        imageName: "pizza2", title: "Pizza Special", category: .food, price: 15.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 2.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Grdace", note: "Loved the ambiance", price: 19.98,
                items: [
                    MenuItem(
                        imageName: "sashimi", title: "Sashimi", category: .food, price: 16.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 2.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Hucgo", note: "Thanks!", price: 20.97,
                items: [
                    MenuItem(
                        imageName: "noodle", title: "Noodle", category: .food, price: 9.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "sashimi", title: "Sashimi", category: .food, price: 10.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: yesterday)!,
                type: .online),

            Order(
                id: UUID(), user: "Isvy", note: "Quick and easy", price: 14.98,
                items: [
                    MenuItem(
                        imageName: "firedRice", title: "Fried Rice", category: .food, price: 8.99,
                        quantity: 1),
                    MenuItem(
                        imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99,
                        quantity: 1),
                ],
                createdAt: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: yesterday)!,
                type: .inStore),

            Order(
                id: UUID(), user: "Jacck", note: "Very satisfying", price: 29.96,
                items: [
                    MenuItem(
                        imageName: "xiaolongbao", title: "Xiaolongbao", category: .food,
                        price: 9.99, quantity: 2),
                    MenuItem(
                        imageName: "cake", title: "Cake", category: .dessert, price: 4.99,
                        quantity: 2),
                ],
                createdAt: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: yesterday)!,
                type: .online),
        ])
    }
}
