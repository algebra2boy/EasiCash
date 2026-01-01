//
//  AnalyticSummaryCard.swift
//  EasiCash
//
//  Created by CHENGTAO on 12/31/25.
//

import SwiftUI

struct AnalyticSummaryCard: View {
    let title: String
    let value: String
    let trend: Double?
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(color)
                    .padding(10)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Spacer()

                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(Int(abs(trend) * 100))%")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(trend >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend >= 0 ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HStack {
        AnalyticSummaryCard(
            title: "Revenue", value: "$1,240", trend: 0.12, systemImage: "dollarsign.circle.fill",
            color: .blue)
        AnalyticSummaryCard(
            title: "Orders", value: "42", trend: -0.05, systemImage: "cart.fill", color: .orange)
    }
    .padding()
}
