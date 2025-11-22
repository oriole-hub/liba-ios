//
//  CardFlipTransition.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

extension AnyTransition {
    static var cardFlip: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CardFlipModifier(angle: .pi, opacity: 0),
                identity: CardFlipModifier(angle: 0, opacity: 1)
            ),
            removal: .modifier(
                active: CardFlipModifier(angle: -.pi, opacity: 0),
                identity: CardFlipModifier(angle: 0, opacity: 1)
            )
        )
    }
}

struct CardFlipModifier: ViewModifier {
    let angle: Double
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle * 180 / .pi),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .opacity(opacity)
    }
}

struct CardMatchedGeometryModifier: ViewModifier {
    let namespace: Namespace.ID?
    
    func body(content: Content) -> some View {
        if let namespace = namespace {
            content
                .matchedGeometryEffect(id: "libraryCard", in: namespace)
        } else {
            content
        }
    }
}

