//
//  User.swift
//  DTOs
//
//  Created by aristarh on 12.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum User {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension User.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct UserUpdate: Codable {
        public let fullName: String?
        public let birthday: String?
        public let deviceToken: String?
        public let deviceType: String?
    }
}

// MARK: - Responses

public extension User.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct UserResponse: Identifiable, Codable {
        public let id: UUID
        public let fullName: String
        public let email: String
        public let birthday: String?
        public let barcode: String?
        public let deviceType: String?
        public let createdAt: Date
        public let updatedAt: Date
    }
}
