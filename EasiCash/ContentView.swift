//
//  ContentView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI

struct ContentView: View {

    @State private var menuViewModel: MenuViewModel = MenuViewModel()

    @State private var saleViewModel: SaleViewModel = SaleViewModel()

    var body: some View {
        EasiCashMainTabView()
            .environment(menuViewModel)
            .environment(saleViewModel)
            .onAppear(perform: consoleSQLiteDBURL)
    }

    // find where SQLiteDB is in local machine
    // we can get model context through any data source
    // model context is exposed through menu data source for the sake of accessing it
    func consoleSQLiteDBURL() {
        if Platform.isSimulator {
            print(MenuDataSource.shared(isMock: true).getModelContext().sqliteCommand)
        } else {
            print(MenuDataSource.shared(isMock: false).getModelContext().sqliteCommand)
        }
    }
}

#Preview {
    ContentView()
}
