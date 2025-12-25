//
//  AddNewMenuItemTip.swift
//  EasiCash
//
//  Created by Yongye on 8/18/24.
//

import TipKit

struct AddNewMenuItemTip: Tip {
    var title: Text {
        Text("Save new menu Item").bold()
    }

    var message: Text? {
        Text("Add item using photo, name, and price")
    }

    var image: Image? {
        Image(systemName: "lightbulb")
    }
}
