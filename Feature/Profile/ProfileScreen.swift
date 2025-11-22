//
//  ProfileScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct ProfileScreen: View {
    
    @StateObject var state: ProfileState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Error message
                if let errorMessage = state.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                // Logout button
                Button(action: {
                    Task {
                        await state.logout()
                    }
                }) {
                    Text("Выйти")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(state.isLoading ? Color.gray : Color.red)
                        .cornerRadius(14)
                }
                .disabled(state.isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileScreen(state: ProfileState())
}

