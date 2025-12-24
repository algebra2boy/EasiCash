//
//  MenuGridItemView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI

struct MenuGridItemView: View {

    @Environment(MenuViewModel.self) var menuViewModel: MenuViewModel

    var item: MenuItem
    
    @State private var presentEditMenuItemSheetView: Bool = false

    private var quantity: Int {
        let filteredItems = menuViewModel.customerSelectedItems.items.filter { item.id == $0.id }
        if filteredItems.isEmpty { return 0 }
        return filteredItems[0].quantity
    }

    var body: some View {
        Button {
            withAnimation {
                menuViewModel.addOrder(with: item)
            }
        } label: {
            VStack(alignment: .leading) {
                if let imageData = item.image, let image = UIImage(data: imageData) {
                    Image(uiImage: image).roundedImageStyle()

                } else {
                    Image(item.imageName).roundedImageStyle()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 24, weight: .medium))
                    Text("Price: $\(String(format: "%.2f", item.price))")
                        .font(.system(size: 18, weight: .regular))
                }
            }
            .padding(.horizontal, 10)
            .overlay(alignment: .topTrailing) {
                if quantity > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 25)
                        .padding([.horizontal, .vertical], 3)
                        .overlay(alignment: .center) {
                            Text("\(quantity)")
                                .foregroundStyle(.white)
                        }
                }
            }
            .overlay(alignment: .topLeading) {
                Menu {
                    Button {
                        presentEditMenuItemSheetView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        menuViewModel.deleteMenuItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
        }
        .buttonStyle(.plain)
        .onTapGesture(count: 2) {
            withAnimation {
                menuViewModel.removeOrder(with: item)
            }
        }
        .sheet(isPresented: $presentEditMenuItemSheetView) {
            EditMenuItemSheetView(presentEditMenuItemSheetView: $presentEditMenuItemSheetView, menuItem: item)
        }
    }

}

#Preview {
    let viewModel: MenuViewModel = MenuViewModel()
    MenuGridItemView(item: viewModel.menuItems[0])
        .environment(viewModel)
}
