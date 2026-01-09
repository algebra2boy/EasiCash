//
//  InsightSuggestionView.swift
//  EasiCash
//
//  Created by CHENGTAO on 12/31/25.
//

import SwiftUI

struct InsightSuggestionView: View {
    let insights: [Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Business Insights")
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(insights) { insight in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: insight.systemImage)
                                    .foregroundStyle(insight.color)
                                Text(insight.title)
                                    .font(.headline)
                            }

                            Text(insight.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(3)

                            Spacer()
                        }
                        .padding()
                        .frame(width: 200, height: 140)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    InsightSuggestionView(insights: [
        Insight(
            title: "Strong Growth", message: "Revenue is up 12% from yesterday. Keep it up!",
            systemImage: "arrow.up.right.circle.fill", color: .green),
        Insight(
            title: "Popular Item", message: "Burger is selling fast today (45 orders).",
            systemImage: "star.fill", color: .orange),
    ])
}
