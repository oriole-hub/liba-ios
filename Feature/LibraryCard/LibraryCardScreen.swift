//
//  LibraryCardScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

struct LibraryCardScreen: View {
    
    @StateObject var state: LibraryCardState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Reversed Reader Ticket View
                ReversedReaderTicketView(
                    holderName: state.holderName.isEmpty ? "ИМЯ ДЕРЖАТЕЛЯ" : state.holderName,
                    qrCode: state.qrCode.isEmpty ? "0000000000" : state.qrCode
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Библиотечная карта")
        .navigationBarTitleDisplayMode(.large)
    }
}

