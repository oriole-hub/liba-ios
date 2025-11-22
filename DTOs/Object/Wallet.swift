//
//  Wallet.swift
//  DTOs
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Wallet {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension Wallet.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct WalletMembershipCreate: Codable {
        public let memberName: String
        public let memberNumber: String
        public let barcodeLabel: String?
        public let barcodeValue: String?
        public let expiresAt: Date?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct WalletMembershipUpdate: Codable {
        public let memberName: String
        public let memberNumber: String
        public let barcodeLabel: String?
        public let barcodeValue: String?
        public let expiresAt: Date?
    }
}

// MARK: - Responses

public extension Wallet.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct WalletMembershipResponse: Identifiable, Codable {
        public let id: UUID
        public let userId: UUID
        public let passId: String
        public let passTypeId: String
        public let appleWalletUrl: String?
        public let googleWalletUrl: String?
        public let defaultUrl: String?
        public let qrCodePngApple: String?
        public let qrCodePngGoogle: String?
        public let qrCodeSvgApple: String?
        public let qrCodeSvgGoogle: String?
        public let passHrefApple: String?
        public let passHrefGoogle: String?
        public let walletPin: String?
        public let expiresAt: Date?
        public let validUntil: Date?
        public let createdAt: Date
        public let updatedAt: Date
    }
}

