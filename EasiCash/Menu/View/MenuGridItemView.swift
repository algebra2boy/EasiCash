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
    @State private var tapWorkItem: DispatchWorkItem?

    private var quantity: Int {
        let filteredItems = menuViewModel.customerSelectedItems.items.filter { item.id == $0.id }
        if filteredItems.isEmpty { return 0 }
        return filteredItems[0].quantity
    }

    var body: some View {
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
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    // Cancel single tap if double tap detected
                    tapWorkItem?.cancel()
                    withAnimation {
                        menuViewModel.removeOrder(with: item)
                    }
                }
        )
        .onTapGesture {
            // Handle single tap with a delay to detect double taps
            let workItem = DispatchWorkItem {
                withAnimation {
                    menuViewModel.addOrder(with: item)
                }
            }
            tapWorkItem?.cancel()
            tapWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
        .contextMenu {
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
