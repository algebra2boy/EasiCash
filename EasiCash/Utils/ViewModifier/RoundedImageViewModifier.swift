//
//  RoundedImageViewModifier.swift
//  EasiCash
//
//  Created by Yongye on 9/21/24.
//

import SwiftUI

public struct RoundedImageViewModifier: ViewModifier {

    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension Image {
    func roundedImageStyle(width: CGFloat = 150, height: CGFloat = 150, cornerRadius: CGFloat = 15) -> some View {
        self
            .resizable()
            .modifier(RoundedImageViewModifier(width: width, height: height, cornerRadius: cornerRadius))
    }
}
