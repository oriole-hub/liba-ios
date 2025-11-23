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
                        
                        // Author
                        if !state.author.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Автор: \(state.author)")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        
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
                    .padding(.bottom, 120) // Space for buttons
                }
            }
            .refreshable {
                await state.refresh()
            }
            
            // Buttons overlayed on screen
            VStack(spacing: 12) {
                // Extend loan button (if active loan exists)
                if let activeLoan = state.activeLoan {
                    Button(action: {
                        // Устанавливаем начальную дату перед открытием листа
                        let calendar = Calendar.current
                        let currentDueDate = calendar.startOfDay(for: activeLoan.dueDate)
                        let today = calendar.startOfDay(for: Date())
                        // Если текущая дата возврата меньше сегодня, начинаем с сегодня + 1 день
                        if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDueDate > today ? currentDueDate : today) {
                            state.selectedExtendDate = nextDay
                        } else {
                            state.selectedExtendDate = currentDueDate > today ? currentDueDate : today
                        }
                        state.showExtendLoanSheet = true
                    }) {
                        Text("Продлить займ")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Reserve book button
                Button(action: {
                    state.destination = .loanCreation(LoanCreationState(isbn: state.isbn))
                }) {
                    Text("Взять на прочтение")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(state.availableInstancesCount > 0 ? Color.accentColor : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(state.availableInstancesCount == 0)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(state.bookName)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $state.destination.loanCreation) { loanCreationState in
            loanCreationState.screen
        }
        .sheet(isPresented: $state.showExtendLoanSheet) {
            // Сбрасываем ошибку при закрытии листа
            state.extendLoanError = nil
        } content: {
            ExtendLoanSheet(state: state)
        }
        .onAppear {
            // Проверяем активный займ при появлении экрана
            if state.activeLoan == nil && !state.isLoadingLoan {
                Task {
                    await state.checkActiveLoan()
                }
            }
        }
    }
}

// MARK: - Extend Loan Sheet

struct ExtendLoanSheet: View {
    @ObservedObject var state: BookState
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current loan info
                    if let activeLoan = state.activeLoan {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Текущий займ")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Дата возврата: \(dateFormatter.string(from: activeLoan.dueDate))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                if let bookTitle = activeLoan.bookTitle {
                                    Text("Книга: \(bookTitle)")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Date picker section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Новая дата возврата")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "",
                            selection: $state.selectedExtendDate,
                            in: state.extendLoanDateRange,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    .padding(.horizontal, 16)
                    
                    // Extend button
                    Button(action: {
                        Task {
                            await state.extendLoan(dueDate: state.selectedExtendDate)
                        }
                    }) {
                        Text("Продлить займ")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(state.isLoadingLoan ? Color.gray : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(state.isLoadingLoan || state.activeLoan == nil)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Продление займа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { state.extendLoanError != nil },
                    set: { if !$0 { state.extendLoanError = nil } }
                )
            ) {
                Button("OK") {
                    state.extendLoanError = nil
                }
            } message: {
                if let errorMessage = state.extendLoanError {
                    Text(errorMessage)
                }
            }
            .alert(
                "Успех",
                isPresented: $state.showExtendLoanSuccess
            ) {
                Button("OK") {
                    state.showExtendLoanSuccess = false
                    dismiss()
                }
            } message: {
                if let updatedLoan = state.activeLoan {
                    Text("Займ успешно продлен до \(dateFormatter.string(from: updatedLoan.dueDate))")
                } else {
                    Text("Займ успешно продлен")
                }
            }
        }
    }
}

