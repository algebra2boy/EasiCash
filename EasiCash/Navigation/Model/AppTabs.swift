//
//  AppTabs.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

enum AppTabs: String, Equatable, Hashable, Identifiable {
    case menu
    case sale
    case analytic

    var id: AppTabs { self }

    var name: String {
        switch self {
        case .menu:
            "Menu"
        case .sale:
            "Sale"
        case .analytic:
            "Analytic"
        }
    }

    var icon: String {
        switch self {
        case .menu:
            "fork.knife"
        case .sale:
            "menucard"
        case .analytic:
            "dollarsign"
        }
    }

    var customizationID: String {
        "EasiCash-Tab-View-\(self.name)"
    }
}
