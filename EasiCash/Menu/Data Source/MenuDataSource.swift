//
//  MenuDataSource.swift
//  EasiCash
//
//  Created by Yongye on 9/24/24.
//

import Foundation
import SwiftData

class MenuDataSource {

    private let modelContainer: ModelContainer

    private let modelContext: ModelContext

    @MainActor
    static var shared = MenuDataSource()

    @MainActor
    private init() {
        let isPreview: Bool = Platform.isPreview
        let configurations =
            isPreview
            ? ModelConfiguration(isStoredInMemoryOnly: true)
            : ModelConfiguration(isStoredInMemoryOnly: false)

        // swiftlint:disable:next force_try
        self.modelContainer = try! ModelContainer(
            for: MenuItem.self, CheckOutList.self, Order.self,
            configurations: configurations
        )
        self.modelContext = modelContainer.mainContext
        self.modelContext.autosaveEnabled = true  // false by default if making a new context by hand

        if isPreview || fetchMenuItems().isEmpty {
            for menuItem in Self.sampleMeunItems {
                self.modelContext.insert(menuItem)
            }
            self.modelContext.insert(Self.sampleCustomerSelectedItems)
        }

        if isPreview || fetchOrders().isEmpty {
            generateMockOrders()
        }
    }

    func getModelContainer() -> ModelContainer {
        modelContainer
    }

    func getModelContext() -> ModelContext {
        modelContext
    }

    func fetchMenuItems() -> [MenuItem] {
        do {
            let descriptor = FetchDescriptor<MenuItem>()
            let menuItems = try modelContext.fetch(descriptor)
            return menuItems
        } catch {
            print("error fetching menu items")
            return []
        }
    }

    func addNewMenuItem(with item: MenuItem) {
        modelContext.insert(item)
    }

    func updateMenuItem(_ item: MenuItem) {
        // SwiftData automatically tracks changes, but we can explicitly save if needed
        try? modelContext.save()
    }

    func deleteMenuItem(_ item: MenuItem) {
        modelContext.delete(item)
    }

    func fetchOrders() -> [Order] {
        do {
            let descriptor = FetchDescriptor<Order>(sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ])
            let orders = try modelContext.fetch(descriptor)
            return orders
        } catch {
            print("error fetching orders: \(error)")
            return []
        }
    }

    func addOrder(_ order: Order) {
        modelContext.insert(order)
    }

    func deleteOrder(_ order: Order) {
        modelContext.delete(order)
    }

    func generateMockOrders() {
        let calendar = Calendar.current
        let today = Date()

        // Generate data for the past 30 days
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                continue
            }

            // Random number of orders per day (e.g., 5 to 15)
            let ordersCount = Int.random(in: 5...15)

            for _ in 0..<ordersCount {
                // Random time between 10 AM and 9 PM
                let hour = Int.random(in: 10...21)
                let minute = Int.random(in: 0...59)
                guard
                    let orderDate = calendar.date(
                        bySettingHour: hour, minute: minute, second: 0, of: date)
                else { continue }

                // Random items for this order
                var orderItems: [MenuItem] = []
                let itemsCount = Int.random(in: 1...4)

                for _ in 0..<itemsCount {
                    let randomItem = Self.sampleMeunItems.randomElement()!
                    // Create a copy for the order
                    let orderItem = MenuItem(
                        imageName: randomItem.imageName,
                        image: randomItem.image,
                        title: randomItem.title,
                        category: randomItem.category,
                        price: randomItem.price,
                        quantity: Int.random(in: 1...3)
                    )
                    orderItems.append(orderItem)
                }

                let totalPrice = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
                let orderType: OrderType = Bool.random() ? .online : .inStore

                let order = Order(
                    user: "Guest \(Int.random(in: 1000...9999))",
                    note: "",
                    price: totalPrice,
                    items: orderItems,
                    createdAt: orderDate,
                    type: orderType
                )

                modelContext.insert(order)
            }
        }
    }
}

extension MenuDataSource {
    static var sampleMeunItems: [MenuItem] = [
        // food
        .init(imageName: "burger", title: "Burger", category: .food, price: 12.99),
        .init(imageName: "firedRice", title: "Fried Rice", category: .food, price: 8.99),
        .init(imageName: "noodle", title: "Noodle", category: .food, price: 9.99),
        .init(imageName: "pho", title: "Pho", category: .food, price: 11.99),
        .init(imageName: "pizza", title: "Pizza", category: .food, price: 14.99),
        .init(imageName: "pizza2", title: "Pizza Special", category: .food, price: 15.99),
        .init(imageName: "sashimi", title: "Sashimi", category: .food, price: 16.99),
        .init(imageName: "sushi", title: "Sushi", category: .food, price: 13.99),
        .init(imageName: "xiaolongbao", title: "Xiaolongbao", category: .food, price: 9.99),

        // drink
        .init(imageName: "thaiTea", title: "Thai Tea", category: .drink, price: 3.99),
        .init(imageName: "bobaTea", title: "Boba Tea", category: .drink, price: 4.99),
        .init(imageName: "coffee", title: "Coffee", category: .drink, price: 2.99),
        .init(imageName: "tea", title: "Tea", category: .drink, price: 1.49),
        .init(imageName: "yogurt", title: "Yogurt", category: .drink, price: 2.49),
        .init(imageName: "bananaShake", title: "Banana Shake", category: .drink, price: 3.19),

        // dessert
        .init(imageName: "cake", title: "Cake", category: .dessert, price: 2.99),
        .init(imageName: "iceCream", title: "Ice Cream", category: .dessert, price: 5.99),
    ]

    static var sampleCustomerSelectedItems: CheckOutList {
        .init(items: [Self.sampleMeunItems[0]])
    }
}
