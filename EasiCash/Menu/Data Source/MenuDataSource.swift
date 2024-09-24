//
//  MenuDataSource.swift
//  EasiCash
//
//  Created by Yongye on 9/24/24.
//

import SwiftData

class MenuDataSource {

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = MenuDataSource()

    @MainActor
    private init() {
        // swiftlint:disable:next force_try
        self.modelContainer = try! ModelContainer(for: MenuItem.self, CheckOutList.self)
        self.modelContext = modelContainer.mainContext
        self.modelContext.autosaveEnabled = true // autosaveEnable is false by default if making a new context by hand
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
}
