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
    
    @State private var showDeleteConfirmation: Bool = false

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
                        // Remove animation wrapper for instant response
                        if item.quantity > 1 {
                            item.quantity -= 1
                        } else {
                            showDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: item.quantity > 1 ? "minus" : "trash")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
                    .confirmationDialog("Remove Item", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                        Button("Remove", role: .destructive) {
                            itemDeleteHandler()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to remove \"\(item.title)\" from the order?")
                    }

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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                // TODO: add delete handler here
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {

    @Previewable @State var item: MenuItem = MenuViewModel().menuItems[0]

    List {
        CheckoutListItemView(item: $item, itemDeleteHandler: {})
    }
}
