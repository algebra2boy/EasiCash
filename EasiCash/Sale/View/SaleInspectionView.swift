//
//  SaleInspectionView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI
import Foundation

struct SaleInspectionView: View {
    var order: Order

    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .leading, spacing: 20) {
                Text(order.user)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .padding(.leading)
                    .offset(x: -18)

                Divider()

                // Order ID
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order ID")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(order.id.uuidString)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Date and Order Type Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order Created")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(order.createdAt.formatted(.dateTime))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order Type")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(order.type.rawValue.capitalized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
                .padding(.bottom, 6)

                Divider()

                // Items Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Items")
                        .font(.headline)
                        .foregroundColor(.primary)

                    ForEach(order.items) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.leading)
                            }
                            Spacer()
                            Text("\(String(format: "$%.2f", item.price)) x \(item.quantity)")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.bottom, 6)

                Divider()

                // Total Price Section
                HStack {
                    Spacer()
                    Text("Total: \(String(format: "$%.2f", order.price))")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .cornerRadius(10)
            .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }

}

#Preview {
    SaleInspectionView(order: Order(
        id: UUID(),
        user: "Hugo",
        note: "Love the food",
        price: 49.99,
        items: [MenuItem(imageName: "burger", title: "Item1", category: .food, price: 49.99, quantity: 2)],
        createdAt: Date(),
        type: .online))
}
