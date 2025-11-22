//
//  LoginState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class LoginState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.authService) private var authService
    
    lazy var screen = LoginScreen(state: self)
    lazy var registerState = RegisterState(loginState: self)
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case openRegisterScreen(String = "openRegisterScreen")
    }
    
    @Published var destination: Destination?
    
    // MARK: Init
    
    init() {}
    
    // MARK: Actions
    
    @MainActor
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters = Auth.Parameters.UserLogin(
                email: email,
                password: password
            )
            let _ = try await authService.login(parameters: parameters)
            // TODO: Handle successful login (e.g., navigate to main screen)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

