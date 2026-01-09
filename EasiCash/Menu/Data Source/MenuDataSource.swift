//
//  MenuDataSource.swift
//  EasiCash
//
//  Created by Yongye on 9/24/24.
//

import SwiftData
import Foundation

class MenuDataSource {

    private let modelContainer: ModelContainer

    private let modelContext: ModelContext

    @MainActor
    static var shared = MenuDataSource()

    @MainActor
    private init() {
        let isPreview: Bool = Platform.isPreview
        let configurations = isPreview
        ? ModelConfiguration(isStoredInMemoryOnly: true)
        : ModelConfiguration(isStoredInMemoryOnly: false)

        // swiftlint:disable:next force_try
        self.modelContainer = try! ModelContainer(
            for: MenuItem.self, CheckOutList.self, Order.self,
            configurations: configurations
        )
        self.modelContext = modelContainer.mainContext
        self.modelContext.autosaveEnabled = true // false by default if making a new context by hand

        if isPreview {
            for menuItem in Self.sampleMeunItems {
                self.modelContext.insert(menuItem)
            }

            self.modelContext.insert(Self.sampleCustomerSelectedItems)
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
            let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
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
        .init(imageName: "thaiTea", title: "thai Tea", category: .drink, price: 3.99),
        .init(imageName: "bobaTea", title: "boba Tea", category: .drink, price: 4.99),
        .init(imageName: "coffee", title: "coffee", category: .drink, price: 2.99),
        .init(imageName: "tea", title: "tea", category: .drink, price: 1.49),
        .init(imageName: "yogurt", title: "yogurt", category: .drink, price: 2.49),
        .init(imageName: "bananaShake", title: "banana Shake", category: .drink, price: 3.19),

        // dessert
        .init(imageName: "cake", title: "cake", category: .dessert, price: 2.99),
        .init(imageName: "iceCream", title: "ice Cream", category: .dessert, price: 5.99)
    ]

    static var sampleCustomerSelectedItems: CheckOutList {
        .init(items: [Self.sampleMeunItems[0]])
    }
}