//
//  LibraryCardState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation

final class LibraryCardState: ObservableObject, Identifiable {
    let id = UUID()
    @Published var qrCode: String
    @Published var holderName: String
    
    lazy var screen = LibraryCardScreen(state: self)
    
    init(qrCode: String = "", holderName: String = "") {
        self.qrCode = qrCode
        self.holderName = holderName
    }
}

