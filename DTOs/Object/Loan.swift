//
//  Loan.swift
//  DTOs
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Loan {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension Loan.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct LoanReserveRequest: Codable {
        public let bookInstanceId: UUID
        public let dueDate: Date
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct LoanExtendRequest: Codable {
        public let dueDate: Date
    }
}

// MARK: - Responses

public extension Loan.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct LoanResponse: Codable {
        public let id: UUID
        public let userId: UUID
        public let bookInstanceId: UUID
        public let reservedAt: Date
        public let issuedAt: Date?
        public let dueDate: Date
        public let returnedAt: Date?
        public let status: String
        public let createdAt: Date
        public let updatedAt: Date
    }
    
    struct LoanDetailResponse: Codable {
        public let id: UUID
        public let userId: UUID
        public let bookInstanceId: UUID
        public let reservedAt: Date
        public let issuedAt: Date?
        public let dueDate: Date
        public let returnedAt: Date?
        public let status: String
        public let createdAt: Date
        public let updatedAt: Date
        public let bookTitle: String?
        public let bookAuthor: String?
        public let inventoryNumber: String?
    }
}

