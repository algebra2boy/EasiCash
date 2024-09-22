//
//  AddNewMenuItemSheetView.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import SwiftUI
import PhotosUI

struct AddNewMenuItemSheetView: View {

    @Environment(MenuViewModel.self) var viewModel: MenuViewModel

    @Binding var presentAddMenuItemSheetView: Bool

    @State private var newMenuItemTitle: String = ""
    @State private var newMenuItemPrice: Double = 0
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedCategory: MenuCategory = .food

    var body: some View {
        NavigationStack {
            VStack {
                List {

                    Section {
                        PhotosPicker("Select a picture", selection: $pickerItem, matching: .images)
                    } header: {
                        Text("Upload an image")
                    }

                    Section {
                        TextField("Title", text: $newMenuItemTitle)
                    } header: {
                        Text("Title")
                    }

                    Section {
                        TextField("Price", value: $newMenuItemPrice, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Price")
                    }

                    Section {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(MenuCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    } header: {
                        Text("Category")
                    }

                }
                .onChange(of: pickerItem) {
                    Task {
                        selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
                    }
                }
            }
            .navigationTitle("Add new menu item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentAddMenuItemSheetView = false
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: fix data type here
//                        viewModel.menuItems.append(
//                            .init(imageName: newMenuItemTitle,
//                                  image: selectedImage,
//                                  title: newMenuItemTitle,
//                                  category: selectedCategory,
//                                  price: newMenuItemPrice)
//                        )

                        presentAddMenuItemSheetView = false
                    } label: {
                        Text("Submit")
                    }
                    .disabled(newMenuItemTitle.isEmpty || newMenuItemPrice <= 0 || selectedImage == nil)
                }
            }
        }
    }

    func add(number: Int) {

    }
}

#Preview {
    @Previewable @State var present: Bool = false
    AddNewMenuItemSheetView(presentAddMenuItemSheetView: $present)
        .environment(MenuViewModel())
}
