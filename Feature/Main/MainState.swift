//
//  MainState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class MainState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.bookService) private var bookService
    
    @Published var searchText: String = ""
    @Published var books: [Book.Responses.BookDetailResponse] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    private var currentSkip: Int = 0
    private let limit: Int = 20
    @Published var hasMoreBooks: Bool = true
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case book(BookState)
        case libraryCard(LibraryCardState)
        case profile(ProfileState)
    }
    
    @Published var destination: Destination?
    @Published var showBarcodeScanner: Bool = false
 
    lazy var screen = MainScreen(state: self)
    
    // MARK: Init
    
    init() {}
    
    // MARK: Actions
    
    @MainActor
    func loadBooks() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentSkip = 0
        
        do {
            let loadedBooks = try await bookService.getAllBooks(skip: 0, limit: limit)
            books = loadedBooks
            currentSkip = loadedBooks.count
            hasMoreBooks = loadedBooks.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreBooks() async {
        guard !isLoadingMore, !isLoading, hasMoreBooks else { return }
        
        isLoadingMore = true
        
        do {
            let loadedBooks = try await bookService.getAllBooks(skip: currentSkip, limit: limit)
            books.append(contentsOf: loadedBooks)
            currentSkip += loadedBooks.count
            hasMoreBooks = loadedBooks.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
}
