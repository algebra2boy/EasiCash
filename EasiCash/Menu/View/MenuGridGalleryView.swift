//
//  MenuGridGalleryView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI
import PhotosUI

struct MenuGridGalleryView: View {

    @Environment(MenuViewModel.self) var viewModel: MenuViewModel

    @State private var selectedCategory: MenuCategory = .food

    @State private var presentAddMenuItemSheetView: Bool = false

    @Binding var submissionTapped: Bool

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    // Note: add a tip here to inform what the plus button does
    let addNewMenuItemTip = AddNewMenuItemTip()

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
//        .overlay(
//            Group {
//                if submissionTapped {
//                    OrderSubmissionView(submissionTapped: $submissionTapped)
//                        .transition(.scale)
//                }
//            }
//        )
    }
}

#Preview {
    NavigationStack {
        MenuGridGalleryView(submissionTapped: .constant(false))
            .environment(MenuViewModel())
            .previewableTip()
    }
}
