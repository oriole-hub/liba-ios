//
//  LoanCreationScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

struct LoanCreationScreen: View {
    
    @StateObject var state: LoanCreationState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Book preview section
                    if let book = state.book {
                        HStack(spacing: 16) {
                            // Book image
                            AsyncImage(url: URL(string: book.urlPic ?? "")) { phase in
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
                            .frame(width: 100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Book info
                            VStack(alignment: .leading, spacing: 8) {
                                Text(book.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Text(book.author)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Text("ISBN: \(book.isbn)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    } else if state.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    // Date picker section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Дата возврата")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                        
                        DatePicker(
                            "",
                            selection: $state.selectedDate,
                            in: state.dateRange,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(.horizontal, 16)
                    }
                    
                    // Reserve button
                    Button(action: {
                        Task {
                            await state.reserveBook()
                        }
                    }) {
                        Text("Зарезервировать книгу")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(state.isLoading ? Color.gray : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(state.isLoading || state.book == nil)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Резервирование книги")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if state.book == nil {
                    Task {
                        await state.loadBook()
                    }
                }
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { state.errorMessage != nil },
                    set: { if !$0 { state.errorMessage = nil } }
                )
            ) {
                Button("OK") {
                    state.errorMessage = nil
                }
            } message: {
                if let errorMessage = state.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert(
                "Успех",
                isPresented: $state.showSuccessAlert
            ) {
                Button("OK") {
                    state.showSuccessAlert = false
                    dismiss()
                }
            } message: {
                Text("Книга успешно зарезервирована")
            }
        }
    }
}

