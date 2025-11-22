//
//  FlipCardView.swift
//  Design
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

// MARK: - View

public struct FlipCardView: View {
    
    // MARK: Properties
    
    @Binding var isFlipped: Bool
    
    private let frontView: AnyView
    private let backView: AnyView
    
    // MARK: Init
    
    public init<Front: View, Back: View>(
        isFlipped: Binding<Bool>,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.frontView = AnyView(front())
        self.backView = AnyView(back())
    }
    
    // MARK: Body
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Лицевая сторона
            frontView
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
            
            // Обратная сторона
            backView
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var isFlipped = false
        
        var body: some View {
            FlipCardView(isFlipped: $isFlipped) {
                ReaderTicketView(bottomRightText: "ИВАНОВ И.И.")
            } back: {
                ReversedReaderTicketView(
                    holderName: "ИВАНОВ И.И.",
                    qrCode: "1234567890",
                    pass: nil
                )
            }
            .padding()
            .onTapGesture {
                isFlipped.toggle()
            }
        }
    }
    
    return PreviewWrapper()
}

