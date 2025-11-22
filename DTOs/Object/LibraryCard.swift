//
//  LibraryCard.swift
//  DTOs
//
//  Created by aristarh on 12.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum LibraryCard {
    public enum Responses {}
}

// MARK: - Responses

public extension LibraryCard.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct LibraryCardResponse: Identifiable, Codable {
        public let id: UUID
        public let userId: UUID
        public let cardNumber: String?
        public let barcode: String
        public let isActive: Bool
        public let issuedAt: Date
        public let expiresAt: Date?
    }
}

