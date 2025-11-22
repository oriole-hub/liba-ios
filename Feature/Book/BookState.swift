//
//  BookState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies

final class BookState: ObservableObject, Identifiable {
    
    let id = UUID()
    
    @Published var bookName: String
    @Published var imageURLs: [String?]
    @Published var description: String
    @Published var genre: String?
    let isbn: String
    @Published var availableInstancesCount: Int
    
    @Dependency(\.bookService) private var bookService
    
    lazy var screen = BookScreen(state: self)
    
    init(bookName: String, imageURLs: [String?] = [], description: String = "", genre: String? = nil, isbn: String = "", availableInstancesCount: Int = 0) {
        self.bookName = bookName
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
            self.imageURLs = book.urlPic != nil ? [book.urlPic] : []
            self.description = book.description ?? "Описание книги отсутствует."
            self.genre = book.genre
            self.availableInstancesCount = availableCount
        } catch {
            // Ошибка будет обработана автоматически
            print("Ошибка при обновлении данных книги: \(error.localizedDescription)")
        }
    }
}

