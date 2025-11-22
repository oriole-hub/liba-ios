//
//  RegisterState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import CasePaths

final class RegisterState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.authService) private var authService
    
    lazy var screen = RegisterScreen(state: self)
    
    weak var loginState: LoginState?
    
    @Published var fullName: String = ""
    @Published var birthday: Date = Date()
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case openLoginState(String = "openLoginState")
    }
    
    @Published var destination: Destination?
    
    // MARK: Init
    
    init(loginState: LoginState? = nil) {
        self.loginState = loginState
    }
    
    // MARK: Actions
    
    @MainActor
    func register() async {
        guard !fullName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birthdayString = dateFormatter.string(from: birthday)
            
            let parameters = Auth.Parameters.UserCreate(
                fullName: fullName,
                email: email,
                password: password,
                birthday: birthdayString,
                deviceToken: nil,
                deviceType: nil
            )
            let _ = try await authService.register(parameters: parameters)
            
            // Автоматический логин после успешной регистрации
            let loginParameters = Auth.Parameters.UserLogin(
                email: email,
                password: password
            )
            let _ = try await authService.login(parameters: loginParameters)
            // TODO: Handle successful login (e.g., navigate to main screen)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

