//
//  ContentView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var menuViewModel: MenuViewModel = MenuViewModel()

    @State private var saleViewModel: SaleViewModel = SaleViewModel()

    var body: some View {
        EasiCashMainTabView()
            .environment(menuViewModel)
            .environment(saleViewModel)
            .onAppear(perform: consoleSQLiteDBURL)
    }

    func consoleSQLiteDBURL() {
        print(modelContext.sqliteCommand)
    }
}

#Preview {
    ContentView()
}
