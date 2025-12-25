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

    // Internal State

    @State private var newMenuItemTitle: String = ""

    @State private var newMenuItemPrice: Double = 0.99

    @State private var pickerItem: PhotosPickerItem?

    @State private var selectedImage: Image?

    @State private var selectedCategory: MenuCategory = .food

    var isAbleToSubmit: Bool {
        newMenuItemTitle.isEmpty || newMenuItemPrice <= 0 || selectedImage == nil
    }

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        NavigationStack {
            VStack {

                List {

                    Section {
                        PhotosPicker("Select a picture", selection: $pickerItem, matching: .images)

                        if let selectedImage {
                            HStack {
                                selectedImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 250, height: 200)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } header: {
                        Text("Upload an image")
                    }

                    Section {
                        TextField("Title", text: $newMenuItemTitle)
                    } header: {
                        Text("Title")
                    }

                    Section {
                        TextField("Price", value: $newMenuItemPrice, formatter: formatter)
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
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: submit) {
                        Text("Submit")
                    }
                    .disabled(isAbleToSubmit)
                }
            }
        }
    }

    func cancel() {
        presentAddMenuItemSheetView = false
    }

    func submit() {
        guard let selectedImage else { return }

        let imagePNGData = ImageRenderer(content: selectedImage).uiImage?.pngData()

        let newItem: MenuItem = .init(
            imageName: newMenuItemTitle,
            image: imagePNGData,
            title: newMenuItemTitle,
            category: selectedCategory,
            price: newMenuItemPrice)

        viewModel.addNewMenuItem(with: newItem)

        presentAddMenuItemSheetView = false
    }
}

#Preview {
    @Previewable @State var present: Bool = false

    AddNewMenuItemSheetView(presentAddMenuItemSheetView: $present)
        .environment(MenuViewModel())
}
