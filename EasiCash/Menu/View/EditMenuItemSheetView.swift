//
//  EditMenuItemSheetView.swift
//  EasiCash
//
//  Created by Auto on 12/19/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditMenuItemSheetView: View {

    @Environment(MenuViewModel.self) var viewModel: MenuViewModel

    @Binding var presentEditMenuItemSheetView: Bool
    
    let menuItem: MenuItem

    // Internal State

    @State private var menuItemTitle: String
    @State private var menuItemPrice: Double
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedCategory: MenuCategory
    @State private var hasImageChanged: Bool = false

    var isAbleToSubmit: Bool {
        menuItemTitle.isEmpty || menuItemPrice <= 0
    }

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    init(presentEditMenuItemSheetView: Binding<Bool>, menuItem: MenuItem) {
        self._presentEditMenuItemSheetView = presentEditMenuItemSheetView
        self.menuItem = menuItem
        self._menuItemTitle = State(initialValue: menuItem.title)
        self._menuItemPrice = State(initialValue: menuItem.price)
        self._selectedCategory = State(initialValue: menuItem.category)
    }

    var body: some View {
        NavigationStack {
            VStack {

                List {

                    Section {
                        PhotosPicker("Select a new picture", selection: $pickerItem, matching: .images)

                        if let selectedImage {
                            HStack {
                                selectedImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 200)
                            }
                            .frame(maxWidth: .infinity)
                        } else if let imageData = menuItem.image, let image = UIImage(data: imageData) {
                            HStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 200)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            HStack {
                                Image(menuItem.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 200)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } header: {
                        Text("Image")
                    }

                    Section {
                        TextField("Title", text: $menuItemTitle)
                    } header: {
                        Text("Title")
                    }

                    Section {
                        TextField("Price", value: $menuItemPrice, formatter: formatter)
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
                        hasImageChanged = true
                    }
                }
            }
            .navigationTitle("Edit menu item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: submit) {
                        Text("Save")
                    }
                    .disabled(isAbleToSubmit)
                }
            }
        }
    }

    func cancel() {
        presentEditMenuItemSheetView = false
    }

    func submit() {
        // Update the menu item properties
        menuItem.title = menuItemTitle
        menuItem.price = menuItemPrice
        menuItem.category = selectedCategory
        
        // Update image if changed
        if hasImageChanged, let selectedImage {
            let imagePNGData = ImageRenderer(content: selectedImage).uiImage?.pngData()
            menuItem.image = imagePNGData
            menuItem.imageName = menuItemTitle // Update image name to match title
        }

        viewModel.updateMenuItem(menuItem)

        presentEditMenuItemSheetView = false
    }
}

#Preview {
    @Previewable @State var present: Bool = false
    let sampleItem = MenuItem(imageName: "burger", title: "Burger", category: .food, price: 12.99)

    EditMenuItemSheetView(presentEditMenuItemSheetView: $present, menuItem: sampleItem)
        .environment(MenuViewModel())
}

