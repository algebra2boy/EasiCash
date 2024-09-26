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

    init(menuItems: [MenuItem] = [], customerSelectedItems: CheckOutList = .init(), isMock: Bool = false) {
        self.dataSource = MenuDataSource.shared(isMock: isMock)
        self.menuItems = self.dataSource?.fetchMenuItems() ?? []
        self.customerSelectedItems = customerSelectedItems
    }

    func addNewMenuItem(with item: MenuItem) {
        guard let dataSource else { return }
        dataSource.addNewMenuItem(with: item)
    }

    func addOrder(with item: MenuItem) {

        let indexWhereItemExists = customerSelectedItems.items.firstIndex { $0.id == item.id }
        //
        //        if let index = indexWhereItemExists {
        //            self.customerSelectedItems.items[index].quantity += 1
        //        } else {
        //            self.customerSelectedItems.items.append(item)
        //        }
    }

    func removeOrder(with item: MenuItem) {

        let indexWhereItemExists = customerSelectedItems.items.firstIndex { $0.id == item.id }

        //        if let index = indexWhereItemExists {
        //            let quantity = self.customerSelectedItems.items[index].quantity
        //            if quantity > 1 {
        //                self.customerSelectedItems.items[index].quantity -= 1
        //            } else if quantity == 1 {
        //                self.customerSelectedItems.items.remove(at: index)
        //            }
        //        }
    }

    func emptyOrder() {
        self.customerSelectedItems = .init(items: [])
    }
}

extension MenuViewModel {
    static var mock: MenuViewModel {
        .init(isMock: true)
    }
}
