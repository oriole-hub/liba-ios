//
//  RegisterScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct RegisterScreen: View {
    
    @StateObject var state: RegisterState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Full name field
                    PWFormTextField(
                        text: $state.fullName,
                        config: PWFormTextField.Config(
                            title: "Полное имя",
                            placeholder: "Введите полное имя"
                        )
                    )
                    
                    // Birthday field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Дата рождения")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "",
                            selection: $state.birthday,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
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
                    
                    // Confirm password field
                    PWFormTextField(
                        text: $state.confirmPassword,
                        config: PWFormTextField.Config(
                            title: "Подтвердите пароль",
                            placeholder: "Введите пароль еще раз"
                        )
                    )
                    
                    // Error message
                    if let errorMessage = state.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Register button
                    Button(action: {
                        Task {
                            await state.register()
                        }
                    }) {
                        Text("Зарегистрироваться")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(state.isLoading ? Color.gray : Color.blue)
                            .cornerRadius(14)
                    }
                    .disabled(state.isLoading)
                    
                    // Login navigation button
                    Button {
                        state.destination = .openLoginState()
                    } label: {
                        Text("Уже есть аккаунт? Войти")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $state.destination.openLoginState) { _ in
                state.loginState?.screen
            }
        }
    }
}

#Preview {
    RegisterScreen(state: RegisterState())
}

