//
//  MenuGridGalleryView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import PhotosUI
import SwiftUI

struct MenuGridGalleryView: View {

    @Environment(MenuViewModel.self) var viewModel: MenuViewModel

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    @State private var selectedCategory: MenuCategory = .food

    @State private var presentAddMenuItemSheetView: Bool = false

    @Binding var submissionTapped: Bool

    var addNewMenuItemTip = AddNewMenuItemTip()

    private var filteredMenuItems: [MenuItem] {
        viewModel.menuItems.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ScrollView {
            FilterFoodCategoryChipsView(selectedCategory: $selectedCategory)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredMenuItems) { item in
                    MenuGridItemView(item: item)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    presentAddMenuItemSheetView.toggle()
                } label: {
                    Image(systemName: "plus")
                }
                .popoverTip(addNewMenuItemTip)
            }
        }
        .sheet(isPresented: $presentAddMenuItemSheetView) {
            AddNewMenuItemSheetView(presentAddMenuItemSheetView: $presentAddMenuItemSheetView)
        }
        .alert("Order Submitted", isPresented: $submissionTapped) {
            Button("OK", role: .cancel) {
                submissionTapped = false
            }
        } message: {
            Text("Your order has been submitted!")
        }
    }
}

#Preview {
    NavigationStack {
        MenuGridGalleryView(submissionTapped: .constant(false))
            .environment(MenuViewModel.mock)
    }
}
