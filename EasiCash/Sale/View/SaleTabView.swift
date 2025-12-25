//
//  SaleTabView.swift
//  EasiCash
//
//  Created by Yongye on 8/16/24.
//

import SwiftUI
import Foundation

struct SaleTabView: View {

    @Environment(SaleViewModel.self) var viewModel: SaleViewModel

    @State private var isInspectorPresented: Bool = false

    @State private var selectedOrderID: Order.ID?
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var orderToDelete: Order?

    private var selectedOrder: Order? {
        guard let selectedOrderID else { return nil }

        return viewModel.saleHistory.filter { $0.id == selectedOrderID }[0]
    }

    var body: some View {
        NavigationStack {
            Table(viewModel.saleHistory, selection: $selectedOrderID) {
                TableColumn("Order ID") { order in
                    Text(order.id.uuidString.prefix(16))
                }

                TableColumn("Price") { order in
                    Text(String(format: "$%.2f", order.price))
                }

                TableColumn("Order Type") { order in
                    Text(order.type.rawValue.capitalized)
                }

                TableColumn("Time of transaction") { order in
                    Text(order.createdAt, formatter: dateFormatter)
                }
            }
            .onChange(of: selectedOrderID) {
                if selectedOrderID != nil {
                    isInspectorPresented = true
                }
            }
            .navigationTitle("Sales")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button(role: .destructive) {
                            if let selectedOrderID = selectedOrderID,
                               let order = viewModel.saleHistory.first(where: { $0.id == selectedOrderID }) {
                                orderToDelete = order
                                showDeleteConfirmation = true
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                        .disabled(selectedOrderID == nil)
                        .confirmationDialog("Delete Order", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                if let order = orderToDelete {
                                    viewModel.deleteOrder(order)
                                    if selectedOrderID == order.id {
                                        selectedOrderID = nil
                                        isInspectorPresented = false
                                    }
                                    orderToDelete = nil
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                orderToDelete = nil
                            }
                        } message: {
                            Text("Are you sure you want to delete this order? This action cannot be undone.")
                        }
                        
                        Button(action: presentItemInspector) {
                            Image(systemName: "info.bubble.fill")
                        }
                        .disabled(selectedOrderID == nil)
                    }
                }
            }
            .inspector(isPresented: $isInspectorPresented) {
                if let selectedOrder {
                    SaleInspectionView(order: selectedOrder)

                }
            }
            .onAppear {
                viewModel.refreshOrders()
            }

        }
    }

    func presentItemInspector() {
        isInspectorPresented.toggle()
    }

    // Date Formatter for displaying date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    SaleTabView()
        .environment(SaleViewModel.mock)
}
