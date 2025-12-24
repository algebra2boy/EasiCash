//
//  MenuViewModel.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import Foundation

@Observable @MainActor class MenuViewModel {

    @ObservationIgnored
    private var dataSource: MenuDataSource?

    var menuItems: [MenuItem]

    var customerSelectedItems: CheckOutList

    var totalPrice: Double {
        return customerSelectedItems
            .items
            .reduce(0) {
                $0 + ($1.price * Double($1.quantity))
            }
    }

    var hasItemInCart: Bool {
        self._customerSelectedItems.items.count > 0
    }

    init(menuItems: [MenuItem] = [], customerSelectedItems: CheckOutList = .init()) {
        self.dataSource = MenuDataSource.shared
        self.menuItems = self.dataSource?.fetchMenuItems() ?? []
        self.customerSelectedItems = customerSelectedItems
    }

    func addNewMenuItem(with item: MenuItem) {
        guard let dataSource else { return }
        dataSource.addNewMenuItem(with: item)
        refreshMenuItems()
    }

    func updateMenuItem(_ item: MenuItem) {
        guard let dataSource else { return }
        dataSource.updateMenuItem(item)
        refreshMenuItems()
    }
    
    func deleteMenuItem(_ item: MenuItem) {
        guard let dataSource else { return }
        dataSource.deleteMenuItem(item)
        refreshMenuItems()
    }
    
    func refreshMenuItems() {
        self.menuItems = dataSource?.fetchMenuItems() ?? []
    }

    func addOrder(with item: MenuItem) {
        // Match cart items by title and price instead of ID to handle cart items with unique UUIDs
        let indexWhereItemExists = customerSelectedItems.items.firstIndex { 
            $0.title == item.title && $0.price == item.price 
        }
        
        if let index = indexWhereItemExists {
            self.customerSelectedItems.items[index].quantity += 1
        } else {
            // Create a copy of the item for the cart with a new UUID to avoid SwiftData conflicts
            // This ensures cart items are unique entities that won't duplicate the original menu items
            let cartItem = MenuItem(
                id: UUID(), // Generate new UUID for cart item to prevent duplicate SwiftData entities
                imageName: item.imageName,
                image: item.image,
                title: item.title,
                category: item.category,
                price: item.price,
                quantity: 1
            )
            self.customerSelectedItems.items.append(cartItem)
        }
    }

    func removeOrder(with item: MenuItem) {
        // Match cart items by title and price instead of ID to handle cart items with unique UUIDs
        guard let index = customerSelectedItems.items.firstIndex(where: { 
            $0.title == item.title && $0.price == item.price 
        }) else {
            return
        }
        
        let quantity = self.customerSelectedItems.items[index].quantity
        if quantity > 1 {
            self.customerSelectedItems.items[index].quantity -= 1
        } else {
            // Remove item immediately without extra checks
            self.customerSelectedItems.items.remove(at: index)
        }
    }

    func emptyOrder() {
        self.customerSelectedItems = .init(items: [])
    }
}
