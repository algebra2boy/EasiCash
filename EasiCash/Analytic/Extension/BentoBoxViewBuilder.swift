//
//  BentoBoxView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI

func bentoBoxView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.9))
            .shadow(radius: 5)
        content()
    }
}
