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
                image.roundedImageStyle()

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
    }

}

#Preview {
    let mock: MenuViewModel = MenuViewModel.mock
    MenuGridItemView(item: mock.menuItems[0])
        .environment(mock)
}
