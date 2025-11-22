//
//  Auth.swift
//  DTOs
//
//  Created by aristarh on 12.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Auth {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension Auth.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct UserCreate: Codable {
        public let fullName: String
        public let email: String
        public let password: String
        public let birthday: String?
        public let deviceToken: String?
        public let deviceType: String?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct UserLogin: Codable {
        public let email: String
        public let password: String
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BodyLogintoken: Codable {
        public let grantType: String?
        public let username: String
        public let password: String
        public let scope: String?
        public let clientId: String?
        public let clientSecret: String?
    }
}

// MARK: - Responses

public extension Auth.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct RegisterResponse: Codable {
        public let message: String
        public let userId: UUID
        public let barcode: String?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct TokenResponse: Codable {
        public let accessToken: String
        public let tokenType: String?
        public let userId: UUID
    }
}
