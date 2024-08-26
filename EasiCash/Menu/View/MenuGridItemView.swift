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

    private var quantity: Int {
        let filteredItems = menuViewModel.customerSelectedItems.items.filter { item.id == $0.id }
        if filteredItems.isEmpty { return 0 }
        return filteredItems[0].quantity
    }

    var body: some View {

        VStack(alignment: .leading) {
            if let image = item.image {
                image
                    .resizable()
                    .frame(width: 150, height: 150)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))

            } else {
                Image(item.imageName)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading) {
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
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .overlay {
                        Text("\(quantity)")
                            .foregroundStyle(.white)
                    }
            }
        }
        .onTapGesture {
            withAnimation {
                menuViewModel.addOrder(with: item)
            }
        }
        .onTapGesture(count: 2) {
            withAnimation {
                menuViewModel.removeOrder(with: item)
            }
        }
        .shadow(radius: 5)
    }

}

#Preview {
    MenuGridItemView(item: MenuViewModel().menuItems[0])
        .environment(MenuViewModel.mock)
}
