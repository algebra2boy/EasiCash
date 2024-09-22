//
//  CheckOutItem.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import Foundation
import SwiftData

@Model
class CheckOutList {

    var id: UUID
    var items: [MenuItem]

    init(id: UUID = UUID(), items: [MenuItem] = []) {
        self.id = id
        self.items = items
    }
}
