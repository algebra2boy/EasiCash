//
//  CheckoutListItemView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//
import SwiftUI

struct CheckoutListItemView: View {

    @Binding var item: MenuItem

    var itemDeleteHandler: () -> Void

    private var quantityFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    init(item: Binding<MenuItem>, itemDeleteHandler: @escaping () -> Void = {}) {
        self._item = item
        self.itemDeleteHandler = itemDeleteHandler
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                Spacer()
                Text(String(format: "$%.2f", item.price))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }

            HStack {
                Text("Quantity:")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                Spacer()

                HStack {
                    Button {
                        if item.quantity > 1 {
                            item.quantity -= 1
                        } else {
                            itemDeleteHandler()
                        }
                    } label: {
                        Image(systemName: item.quantity > 1 ? "minus" : "trash")
                    }
                    .buttonStyle(.plain)
                    .frame(width: 25, height: 50)

                    TextField("Quantity", value: $item.quantity, formatter: quantityFormatter)
                        .frame(width: 50)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)

                    Button {
                        item.quantity += 1
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                    .frame(width: 25, height: 50)
                }
            }
        }
    }
}

#Preview {

    @Previewable @State var item: MenuItem = MenuViewModel.mock.menuItems[0]

    CheckoutListItemView(item: $item, itemDeleteHandler: {})
}
