//
//  Order.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Foundation
import SwiftData

enum OrderType: String, CaseIterable, Codable {
    case online
    case inStore
}

@Model
class Order: Identifiable {
    var id: UUID
    var user: String
    var note: String
    var price: Double
    var items: [MenuItem]
    var createdAt: Date
    var type: OrderType

    init(
        id: UUID = UUID(),
        user: String,
        note: String,
        price: Double,
        items: [MenuItem],
        createdAt: Date = Date.now,
        type: OrderType
    ) {
        self.id = id
        self.user = user
        self.note = note
        self.price = price
        self.items = items
        self.createdAt = createdAt
        self.type = type
    }
}
