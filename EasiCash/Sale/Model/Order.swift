//
//  Order.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import Foundation

enum OrderType: String, CaseIterable {
    case online
    case inStore
}

struct Order: Identifiable {
    let id: UUID
    let user: String
    let note: String
    let price: Double
    let items: [MenuItem]
    let createdAt: Date
    let type: OrderType

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
