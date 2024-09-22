//
//  CheckoutListView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI

struct CheckoutListView: View {

    @Environment(MenuViewModel.self) var menuViewModel: MenuViewModel

    @Environment(SaleViewModel.self) var saleViewModel: SaleViewModel

    @State private var orderType: OrderType = .inStore

    @State private var customerName: String = ""

    @State private var additionalInfo: String = ""

    @State private var isEmptyOrderButtonPressed: Bool = false

    @Binding var submissionTapped: Bool

    var body: some View {
        if menuViewModel.hasItemInCart {
            checkoutView
        } else {
            noItemView
        }
    }

    @ViewBuilder var checkoutView: some View {
        @Bindable var menuViewModel = menuViewModel
        VStack {
            List {
                Section {
                    ForEach($menuViewModel.customerSelectedItems.items) { item in
                        CheckoutListItemView(item: item) {
                            menuViewModel.removeOrder(with: item.wrappedValue)
                            print(menuViewModel.menuItems)
                        }
                    }
                } header: {
                    Text("Order list")
                }

                Section {
                    Picker("Pick order type", selection: $orderType) {
                        ForEach(OrderType.allCases, id: \.self) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Order Type")
                }
                .listRowSeparator(.hidden)

                Section {
                    TextField("Customer Name", text: $customerName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Additional Info", text: $additionalInfo)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Customer Info")
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

            Spacer()

            HStack {
                Text("Total Price:")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: "$%.2f", menuViewModel.totalPrice))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .cornerRadius(10)
            .padding([.leading, .trailing, .bottom], 20)

            HStack(spacing: 20) {
                Button(role: .destructive) {
                    isEmptyOrderButtonPressed.toggle()
                } label: {
                    Text("Empty")
                        .padding(3)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    checkout()
                } label: {
                    Label("Checkout", systemImage: "cart")
                        .padding(3)
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
            }
        }
        .alert("Are you sure you want to clear the order?", isPresented: $isEmptyOrderButtonPressed) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) { emptyListOrder() }
        }
    }

    @ViewBuilder var noItemView: some View {
        ContentUnavailableView {
            Label("No Item", systemImage: "tray.fill")
        } description: {
            Text("New item you added will be shown here.")
        }
    }

    func checkout() {
        withAnimation {
            saleViewModel.addSale(
                with: menuViewModel.customerSelectedItems,
                name: customerName,
                note: additionalInfo,
                type: orderType,
                totalPrice: menuViewModel.totalPrice
            )
            emptyListOrder()
            submissionTapped = true
        }
    }

    func emptyListOrder() {
        withAnimation {
            menuViewModel.emptyOrder()
        }
    }
}

#Preview("with items") {
    CheckoutListView(submissionTapped: .constant(false))
        .environment(MenuViewModel.mock)
        .environment(SaleViewModel.mock)
}

#Preview("without items") {
    CheckoutListView(submissionTapped: .constant(false))
        .environment(MenuViewModel())
        .environment(SaleViewModel.mock)
}
