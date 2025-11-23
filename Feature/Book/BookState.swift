//
//  BookState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class BookState: ObservableObject, Identifiable {
    
    let id = UUID()
    
    @Published var bookName: String
    @Published var author: String
    @Published var imageURLs: [String?]
    @Published var description: String
    @Published var genre: String?
    let isbn: String
    @Published var availableInstancesCount: Int
    @Published var activeLoan: Loan.Responses.LoanDetailResponse?
    @Published var isLoadingLoan: Bool = false
    @Published var showExtendLoanSheet: Bool = false
    @Published var selectedExtendDate: Date = Date()
    @Published var extendLoanError: String?
    @Published var showExtendLoanSuccess: Bool = false
    
    @Dependency(\.bookService) private var bookService
    @Dependency(\.loanService) private var loanService
    
    lazy var screen = BookScreen(state: self)
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case loanCreation(LoanCreationState)
    }
    
    @Published var destination: Destination?
    
    init(bookName: String, author: String = "", imageURLs: [String?] = [], description: String = "", genre: String? = nil, isbn: String = "", availableInstancesCount: Int = 0) {
        self.bookName = bookName
        self.author = author
        self.imageURLs = imageURLs
        self.description = description
        self.genre = genre
        self.isbn = isbn
        self.availableInstancesCount = availableInstancesCount
    }
    
    // MARK: Actions
    
    @MainActor
    func refresh() async {
        guard !isbn.isEmpty else { return }
        
        do {
            let book = try await bookService.getBookByISBN(isbn: isbn)
            
            // Подсчитываем доступные экземпляры (статус "available")
            let availableCount = book.instances.filter { $0.status.lowercased() == "available" }.count
            
            // Обновляем свойства
            self.bookName = book.title
            self.author = book.author
            self.imageURLs = book.urlPic != nil ? [book.urlPic] : []
            self.description = book.description ?? "Описание книги отсутствует."
            self.genre = book.genre
            self.availableInstancesCount = availableCount
            
            // Проверяем активный займ
            await checkActiveLoan()
        } catch {
            // Ошибка будет обработана автоматически
            print("Ошибка при обновлении данных книги: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func checkActiveLoan() async {
        isLoadingLoan = true
        
        do {
            let loans = try await loanService.getMyLoans(includeReturned: false)
            // Ищем активный займ по названию книги
            let activeLoan = loans.first { loan in
                loan.bookTitle == self.bookName && 
                loan.returnedAt == nil && 
                loan.status.lowercased() != "returned"
            }
            self.activeLoan = activeLoan
            // Устанавливаем начальную дату для продления
            if let activeLoan = activeLoan {
                let calendar = Calendar.current
                let currentDueDate = calendar.startOfDay(for: activeLoan.dueDate)
                // Начальная дата - текущая дата возврата + 1 день
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDueDate) {
                    self.selectedExtendDate = nextDay
                } else {
                    self.selectedExtendDate = currentDueDate
                }
            }
        } catch {
            print("Ошибка при проверке активного займа: \(error.localizedDescription)")
            self.activeLoan = nil
        }
        
        isLoadingLoan = false
    }
    
    @MainActor
    func extendLoan(dueDate: Date) async {
        guard let activeLoan = activeLoan else {
            extendLoanError = "Активный займ не найден"
            return
        }
        
        isLoadingLoan = true
        extendLoanError = nil
        
        do {
            let calendar = Calendar.current
            let dueDateStart = calendar.startOfDay(for: dueDate)
            
            let parameters = Loan.Parameters.LoanExtendRequest(dueDate: dueDateStart)
            let updatedLoan = try await loanService.extendLoan(loanId: activeLoan.id, parameters: parameters)
            
            // Обновляем активный займ
            self.activeLoan = updatedLoan
            showExtendLoanSuccess = true
            showExtendLoanSheet = false
            // Обновляем выбранную дату для следующего продления
            let newDueDate = calendar.startOfDay(for: updatedLoan.dueDate)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: newDueDate) {
                self.selectedExtendDate = nextDay
            }
        } catch {
            extendLoanError = error.localizedDescription
        }
        
        isLoadingLoan = false
    }
    
    // Вычисляемое свойство для диапазона дат продления
    var extendLoanDateRange: ClosedRange<Date> {
        guard let activeLoan = activeLoan else {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let maxDate = calendar.date(byAdding: .day, value: 30, to: today) ?? today
            return today...maxDate
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentDueDate = calendar.startOfDay(for: activeLoan.dueDate)
        // Минимальная дата - максимум из сегодня или текущей даты возврата
        let minDate = currentDueDate > today ? currentDueDate : today
        // Максимальная дата - текущая дата возврата + 30 дней
        let maxDate = calendar.date(byAdding: .day, value: 30, to: currentDueDate) ?? currentDueDate
        return minDate...maxDate
    }
}

