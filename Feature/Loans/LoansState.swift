//
//  LoansState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class LoansState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.loanService) private var loanService
    @Dependency(\.bookService) private var bookService
    
    lazy var screen = LoansScreen(state: self)
    
    @Published var loans: [Loan.Responses.LoanDetailResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    enum FilterType: String, CaseIterable {
        case all = "Все"
        case active = "Активные"
        case returned = "Возвращенные"
    }
    
    @Published var selectedFilter: FilterType = .all
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case book(BookState)
    }
    
    @Published var destination: Destination?
    
    // MARK: Computed Properties
    
    var filteredAndGroupedLoans: [(String, [Loan.Responses.LoanDetailResponse])] {
        let filtered = filteredLoans
        let sorted = sortedLoans(filtered)
        return groupedLoans(sorted)
    }
    
    private var filteredLoans: [Loan.Responses.LoanDetailResponse] {
        switch selectedFilter {
        case .all:
            return loans
        case .active:
            return loans.filter { loan in
                loan.returnedAt == nil && loan.status.lowercased() != "returned"
            }
        case .returned:
            return loans.filter { loan in
                loan.returnedAt != nil || loan.status.lowercased() == "returned"
            }
        }
    }
    
    private func sortedLoans(_ loans: [Loan.Responses.LoanDetailResponse]) -> [Loan.Responses.LoanDetailResponse] {
        return loans.sorted { loan1, loan2 in
            // Сортировка по дате резервирования (новые сначала)
            return loan1.reservedAt > loan2.reservedAt
        }
    }
    
    private func groupedLoans(_ loans: [Loan.Responses.LoanDetailResponse]) -> [(String, [Loan.Responses.LoanDetailResponse])] {
        let active = loans.filter { loan in
            loan.returnedAt == nil && loan.status.lowercased() != "returned"
        }
        let returned = loans.filter { loan in
            loan.returnedAt != nil || loan.status.lowercased() == "returned"
        }
        
        var groups: [(String, [Loan.Responses.LoanDetailResponse])] = []
        
        if !active.isEmpty {
            groups.append(("Активные", active))
        }
        if !returned.isEmpty {
            groups.append(("Возвращенные", returned))
        }
        
        return groups
    }
    
    // MARK: Init
    
    init() {}
    
    // MARK: Actions
    
    @MainActor
    func loadLoans() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Загружаем все займы, включая возвращенные
            let loadedLoans = try await loanService.getMyLoans(includeReturned: true)
            self.loans = loadedLoans
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func navigateToBook(loan: Loan.Responses.LoanDetailResponse) async {
        guard let bookTitle = loan.bookTitle, !bookTitle.isEmpty else {
            errorMessage = "Невозможно найти книгу: название отсутствует"
            return
        }
        
        // Пытаемся найти книгу по названию через getAllBooks
        do {
            let books = try await bookService.getAllBooks(skip: 0, limit: 50)
            if let book = books.first(where: { $0.title == bookTitle }) {
                let availableCount = book.instances.filter { $0.status.lowercased() == "available" }.count
                let bookState = BookState(
                    bookName: book.title,
                    imageURLs: book.urlPic != nil ? [book.urlPic] : [],
                    description: book.description ?? "Описание книги отсутствует.",
                    genre: book.genre,
                    isbn: book.isbn,
                    availableInstancesCount: availableCount
                )
                destination = .book(bookState)
            } else {
                errorMessage = "Книга не найдена"
            }
        } catch {
            errorMessage = "Ошибка при поиске книги: \(error.localizedDescription)"
        }
    }
}

