//
//  UserServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol UserServiceProtocol {
    
    func getMe() async throws -> User.Responses.UserResponse
    
    func updateMe(parameters: User.Parameters.UserUpdate) async throws -> User.Responses.UserResponse
}

