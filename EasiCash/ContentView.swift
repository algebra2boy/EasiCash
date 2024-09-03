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
    }
}

#Preview {
    ContentView()
}
