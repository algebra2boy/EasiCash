//
//  AnalyticTab.swift
//  EasiCash
//
//  Created by AI Assistant on 1/15/26.
//

import SwiftUI

struct AnalyticTab<T: Hashable>: View {
    let items: [T]
    @Binding var selected: T
    let title: (T) -> String

    @Namespace private var namespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    let isSelected = selected == item

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = item
                        }
                    } label: {
                        Text(title(item))
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .foregroundStyle(isSelected ? .white : .primary.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(Color(red: 0.1, green: 0.45, blue: 0.9))  // Deep professional blue for contrast
                                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)  // Space for shadow/glow if needed
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var sel = "Today"
        var body: some View {
            AnalyticTab(
                items: ["Today", "Week", "Month", "Year"],
                selected: $sel,
                title: { $0 }
            )
        }
    }
    return PreviewWrapper()
}
