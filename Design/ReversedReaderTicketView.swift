//
//  ReversedReaderTicketView.swift
//  Design
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

// MARK: - View

public struct ReversedReaderTicketView: View {
    
    // MARK: Properties
    
    private let holderName: String
    private let qrCode: String
    
    // MARK: Init
    
    public init(holderName: String, qrCode: String) {
        self.holderName = holderName
        self.qrCode = qrCode
    }
    
    // MARK: Body
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.accentColor
                .cornerRadius(14)
            VStack {
                HStack {
                    Text(holderName)
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
                    QRCodeView(code: qrCode, size: 120)
                    Spacer()
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
    ReversedReaderTicketView(holderName: "ИВАНОВ И.И.", qrCode: "1234567890")
        .padding()
}

