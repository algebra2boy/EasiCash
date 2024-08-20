//
//  SaleViewModel.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import Foundation

@Observable class SaleViewModel {

    var saleHistory: [Order]

    init(saleHistory: [Order] = []) {
        self.saleHistory = saleHistory
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
        .sorted { $0.amount > $1.amount}
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
        saleHistory.reduce(0) { $0 + $1.price }
    }

    func addSale(with checkoutList: CheckOutList, name: String, note: String, type: OrderType, totalPrice: Double) {
        self.saleHistory.append(.init(user: name, note: note, price: totalPrice, items: checkoutList.items, type: type))
    }

    static var mock: SaleViewModel {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        return SaleViewModel(saleHistory: [
            // Orders for Today
            Order(id: UUID(), user: "Alice", note: "First order today", price: 15.98, items: [
                MenuItem(imageName: "burger", title: "burger", category: .food, price: 9.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!, type: .inStore),

            Order(id: UUID(), user: "Bob", note: "Great service!", price: 19.98, items: [
                MenuItem(imageName: "burger", title: "burger", category: .food, price: 9.99, quantity: 2)
            ], createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!, type: .online),

            Order(id: UUID(), user: "Charlie", note: "Quick delivery", price: 25.97, items: [
                MenuItem(imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 2)
            ], createdAt: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!, type: .online),

            Order(id: UUID(), user: "Dave", note: "Loved the wings", price: 39.96, items: [
                MenuItem(imageName: "chickenWings", title: "chicken wings", category: .food, price: 9.99, quantity: 4)
            ], createdAt: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!, type: .inStore),

            Order(id: UUID(), user: "Eve", note: "Tasty!", price: 25.97, items: [
                MenuItem(imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 2)
            ], createdAt: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)!, type: .online),
            // Orders for Today
            Order(id: UUID(), user: "Aldvce", note: "First order today", price: 20.97, items: [
                MenuItem(imageName: "burger", title: "burger", category: .food, price: 9.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 3.99, quantity: 1),
                MenuItem(imageName: "cake", title: "cake", category: .dessert, price: 6.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!, type: .inStore),

            Order(id: UUID(), user: "Boe", note: "Great service!", price: 28.98, items: [
                MenuItem(imageName: "pizza", title: "Pizza", category: .food, price: 14.99, quantity: 2)
            ], createdAt: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!, type: .online),

            Order(id: UUID(), user: "Charliest", note: "Quick delivery", price: 39.96, items: [
                MenuItem(imageName: "sushi", title: "Sushi", category: .food, price: 13.99, quantity: 2),
                MenuItem(imageName: "noodle", title: "Noodle", category: .food, price: 9.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today)!, type: .online),

            Order(id: UUID(), user: "Davve", note: "Loved the wings", price: 39.96, items: [
                MenuItem(imageName: "chickenWings", title: "Chicken Wings", category: .food, price: 9.99, quantity: 4)
            ], createdAt: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today)!, type: .inStore),

            Order(id: UUID(), user: "Exve", note: "Tasty!", price: 30.97, items: [
                MenuItem(imageName: "pho", title: "Pho", category: .food, price: 12.99, quantity: 2),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 4.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today)!, type: .online),

            // Orders for Yesterday
            Order(id: UUID(), user: "Frank", note: "Will order again", price: 9.99, items: [
                MenuItem(imageName: "burger", title: "burger", category: .food, price: 9.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Grace", note: "Loved the ambiance", price: 15.98, items: [
                MenuItem(imageName: "burger", title: "burger", category: .food, price: 9.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Hugo", note: "Thanks!", price: 19.98, items: [
                MenuItem(imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 6.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: yesterday)!, type: .online),

            Order(id: UUID(), user: "Ivy", note: "Quick and easy", price: 19.98, items: [
                MenuItem(imageName: "pho", title: "pho", category: .food, price: 12.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 6.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Jack", note: "Very satisfying", price: 39.96, items: [
                MenuItem(imageName: "chickenWings", title: "chicken wings", category: .food, price: 9.99, quantity: 4)
            ], createdAt: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: yesterday)!, type: .online),
            Order(id: UUID(), user: "Fransk", note: "Will order again", price: 18.98, items: [
                MenuItem(imageName: "pizza2", title: "Pizza Special", category: .food, price: 15.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 2.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Grdace", note: "Loved the ambiance", price: 19.98, items: [
                MenuItem(imageName: "sashimi", title: "Sashimi", category: .food, price: 16.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 2.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Hucgo", note: "Thanks!", price: 20.97, items: [
                MenuItem(imageName: "noodle", title: "Noodle", category: .food, price: 9.99, quantity: 1),
                MenuItem(imageName: "sashimi", title: "Sashimi", category: .food, price: 10.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: yesterday)!, type: .online),

            Order(id: UUID(), user: "Isvy", note: "Quick and easy", price: 14.98, items: [
                MenuItem(imageName: "firedRice", title: "Fried Rice", category: .food, price: 8.99, quantity: 1),
                MenuItem(imageName: "thaiTea", title: "Thai tea", category: .drink, price: 5.99, quantity: 1)
            ], createdAt: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: yesterday)!, type: .inStore),

            Order(id: UUID(), user: "Jacck", note: "Very satisfying", price: 29.96, items: [
                MenuItem(imageName: "xiaolongbao", title: "Xiaolongbao", category: .food, price: 9.99, quantity: 2),
                MenuItem(imageName: "cake", title: "Cake", category: .dessert, price: 4.99, quantity: 2)
            ], createdAt: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: yesterday)!, type: .online)
        ])
    }
}
