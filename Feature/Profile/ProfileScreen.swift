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
                // Карта библиотеки
                Button(action: {
                    state.destination = .libraryMap(LibraryMapState())
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Карта библиотеки")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                
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
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $state.destination.libraryMap) { libraryMapState in
                libraryMapState.screen
            }
        }
    }
}

#Preview {
    ProfileScreen(state: ProfileState())
}

