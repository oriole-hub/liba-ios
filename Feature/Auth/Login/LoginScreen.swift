//
//  LoginScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct LoginScreen: View {
    
    @StateObject var state: LoginState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Email field
                PWFormTextField(
                    text: $state.email,
                    config: PWFormTextField.Config(
                        title: "Email",
                        placeholder: "Введите email"
                    )
                )
                
                // Password field
                PWFormTextField(
                    text: $state.password,
                    config: PWFormTextField.Config(
                        title: "Пароль",
                        placeholder: "Введите пароль"
                    )
                )
                
                // Error message
                if let errorMessage = state.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Login button
                Button(action: {
                    Task {
                        await state.login()
                    }
                }) {
                    Text("Войти")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(14)
                }
                .disabled(state.isLoading)
                
                Button {
                    state.destination = .openRegisterScreen()
                } label: {
                    Text("Зарегистрироваться")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Вход")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $state.destination.openRegisterScreen) { _ in
                state.registerState.screen
            }
        }
    }
}

#Preview {
    LoginScreen(state: LoginState())
}

