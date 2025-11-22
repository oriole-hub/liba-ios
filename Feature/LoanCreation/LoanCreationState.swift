//
//  LoanCreationState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies

final class LoanCreationState: ObservableObject, Identifiable {
    
    // MARK: Properties
    
    let id = UUID()
    let isbn: String
    
    @Dependency(\.bookService) private var bookService
    @Dependency(\.loanService) private var loanService
    
    lazy var screen = LoanCreationScreen(state: self)
    
    @Published var book: Book.Responses.BookDetailResponse?
    @Published var selectedDate: Date
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false
    
    private var availableInstanceId: UUID?
    
    // MARK: Computed Properties
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let minDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let maxDate = calendar.date(byAdding: .day, value: 30, to: today) ?? today
        return minDate...maxDate
    }
    
    // MARK: Init
    
    init(isbn: String) {
        self.isbn = isbn
        // Устанавливаем дату по умолчанию: сегодня + 1 день
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self.selectedDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }
    
    // MARK: Actions
    
    @MainActor
    func loadBook() async {
        guard !isbn.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedBook = try await bookService.getBookByISBN(isbn: isbn)
            self.book = loadedBook
            
            // Находим первый доступный экземпляр
            if let availableInstance = loadedBook.instances.first(where: { $0.status.lowercased() == "available" }) {
                self.availableInstanceId = availableInstance.id
            } else {
                errorMessage = "Нет доступных экземпляров для резервирования"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func reserveBook() async {
        guard let instanceId = availableInstanceId else {
            errorMessage = "Нет доступного экземпляра для резервирования"
            return
        }
        
        // Валидация даты
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let minDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let maxDate = calendar.date(byAdding: .day, value: 30, to: today) ?? today
        
        let selectedDateStart = calendar.startOfDay(for: selectedDate)
        
        if selectedDateStart < minDate || selectedDateStart > maxDate {
            errorMessage = "Дата возврата должна быть от 1 до 30 дней от сегодня"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters = Loan.Parameters.LoanReserveRequest(
                bookInstanceId: instanceId,
                dueDate: selectedDateStart
            )
            let _ = try await loanService.reserveBook(parameters: parameters)
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}


