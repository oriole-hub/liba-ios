//
//  BookScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct BookScreen: View {
    
    @StateObject var state: BookState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Images section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(state.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                                AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay {
                                                ProgressView()
                                            }
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay {
                                                Image(systemName: "book.closed")
                                                    .foregroundColor(.gray)
                                            }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 300, height: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Book details section
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(state.bookName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // Genre
                        if let genre = state.genre, !genre.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.blue)
                                Text("Жанр: \(genre)")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // ISBN
                        if !state.isbn.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "barcode")
                                    .foregroundColor(.blue)
                                Text("ISBN: \(state.isbn)")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Available instances
                        HStack(spacing: 8) {
                            Image(systemName: "books.vertical.fill")
                                .foregroundColor(.green)
                            Text("Доступно экземпляров: \(state.availableInstancesCount)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Description section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Описание")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(state.description.isEmpty ? "Описание книги отсутствует." : state.description)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)
                    
                    // Reviews section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Отзывы")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Review cells will be implemented later
                                // Placeholder for now
                                Text("Отзывы будут добавлены позже")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80) // Space for button
                }
            }
            .refreshable {
                await state.refresh()
            }
            
            // Button overlayed on screen
            Button(action: {
                state.destination = .loanCreation(LoanCreationState(isbn: state.isbn))
            }) {
                Text("взять на прочтение")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(state.availableInstancesCount > 0 ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(state.availableInstancesCount == 0)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(state.bookName)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $state.destination.loanCreation) { loanCreationState in
            loanCreationState.screen
        }
    }
}

