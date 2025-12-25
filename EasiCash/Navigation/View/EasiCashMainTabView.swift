//
//  EasiCashMainTabView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI

struct EasiCashMainTabView: View {

    @AppStorage("QuackTabViewCustomization") var tabViewCustomization: TabViewCustomization

    @State private var selectedTab: AppTabs = .menu

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTabs.menu.name, systemImage: AppTabs.menu.icon, value: .menu) {
                MenuTabView()
            }
            .customizationID(AppTabs.menu.customizationID)

            Tab(AppTabs.sale.name, systemImage: AppTabs.sale.icon, value: .sale) {
                SaleTabView()
            }
            .customizationID(AppTabs.sale.customizationID)

            Tab(AppTabs.analytic.name, systemImage: AppTabs.analytic.icon, value: .analytic) {
                AnalyticTabView()
            }
            .customizationID(AppTabs.analytic.customizationID)

        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)

    }
}

#Preview {
    EasiCashMainTabView()
        .environment(MenuViewModel())
        .environment(SaleViewModel())
}
