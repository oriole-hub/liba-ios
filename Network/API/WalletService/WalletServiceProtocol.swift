//
//  WalletServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol WalletServiceProtocol {
    
    func createMembership(parameters: Wallet.Parameters.WalletMembershipCreate) async throws -> Wallet.Responses.WalletMembershipResponse
    
    func getMyMembership() async throws -> Wallet.Responses.WalletMembershipResponse
    
    func updateMyMembership(parameters: Wallet.Parameters.WalletMembershipUpdate) async throws -> Wallet.Responses.WalletMembershipResponse
    
    func deleteMyMembership() async throws
}

