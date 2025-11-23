//
//  ReaderTickerView.swift
//  Design
//
//  Created by aristarh on 15.11.2025.
//

import SwiftUI
import ColorfulX

// MARK: - View

public struct ReaderTicketView: View {
    
    // MARK: Properties
    
    private let bottomRightText: String
    
    // MARK: Init
    
    public init(bottomRightText: String) {
        self.bottomRightText = bottomRightText
    }
    
    // MARK: Body
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            ColorfulView(color: .aurora, speed: .constant(1.25))
                .cornerRadius(14)
            VStack {
                HStack {
                    Text("ЕДИНЫЙ\nЧИТАТЕЛЬСКИЙ\nБИЛЕТ")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Text(bottomRightText)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(alignment: .trailing)
                }
            }
            .padding(16)
        }
        .aspectRatio(1.68, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ReaderTicketView(bottomRightText: "ФАМИЛИЯ И.О.")
        .padding()
}
