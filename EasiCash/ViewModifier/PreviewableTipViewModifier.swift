//
//  PreviewableTipViewModifier.swift
//  EasiCash
//
//  Created by Yongye on 9/21/24.
//

import SwiftUI
import TipKit

public struct PreviewableTipViewModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .task { Self.initializeTipKit() }
    }
    
    static func initializeTipKit() {
        do {
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            print("Error initializing TipKit: \(error.localizedDescription)")
        }
    }
}

extension View {
    func previewableTip() -> some View {
        modifier(PreviewableTipViewModifier())
    }
}
