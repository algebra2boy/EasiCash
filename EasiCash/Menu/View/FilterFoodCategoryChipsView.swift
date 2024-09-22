//
//  FilterFoodCategoryChipsView.swift
//  EasiCash
//
//  Created by Yongye on 8/17/24.
//

import SwiftUI

struct FilterFoodCategoryChipsView: View {

    @Binding var selectedCategory: MenuCategory

    var body: some View {
        HStack(spacing: 20) {
            ForEach(MenuCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.linear) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category.rawValue)
                        .padding(15)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedCategory == category ? Color.white : Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    selectedCategory == category
                                    ? Color.blue.opacity(2)
                                    : Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.leading, 40)
    }
}

#Preview {

    @Previewable @State var selectedCategory: MenuCategory = .dessert

    FilterFoodCategoryChipsView(selectedCategory: $selectedCategory)
}
