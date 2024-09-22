//
//  EasiCashApp.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI
import SwiftData

@main
struct EasiCashApp: App {

    let container: ModelContainer = {
        let schema = Schema([MenuItem.self, CheckOutList.self])

        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .previewableTip()
                .modelContainer(container)
        }
    }
}
