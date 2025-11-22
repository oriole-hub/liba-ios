//
//  IAuthService.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Combine

// MARK: - Protocol

public protocol AuthServiceProtocol {
    
    var userLoggedInPublisher: AnyPublisher<Bool, Never> { get }
    
    func login(parameters: Auth.Parameters.UserLogin) async throws -> Auth.Responses.TokenResponse
    
    func register(parameters: Auth.Parameters.UserCreate) async throws -> Auth.Responses.RegisterResponse
    
    func loginToken(parameters: Auth.Parameters.BodyLogintoken) async throws -> Auth.Responses.TokenResponse
    
    func logout() async throws
}
