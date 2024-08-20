//
//  MenuItem.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Foundation
import SwiftUI

enum MenuCategory: String, CaseIterable {
    case food
    case drink
    case dessert
}

struct MenuItem: Identifiable, Equatable {

    var id: UUID
    var imageName: String
    var image: Image?
    var title: String
    var price: Double
    var quantity: Int
    var category: MenuCategory

    init(
        id: UUID = UUID(),
        imageName: String,
        image: Image? = nil,
        title: String,
        category: MenuCategory,
        price: Double,
        quantity: Int = 1
    ) {
        self.id = id
        self.imageName = imageName
        self.image = image
        self.title = title
        self.price = price
        self.quantity = quantity
        self.category = category
    }
}
