//
//  BookState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation

final class BookState: ObservableObject, Identifiable {
    
    let id = UUID()
    let bookName: String
    let imageURLs: [String?]
    let description: String
    let genre: String?
    let isbn: String
    let availableInstancesCount: Int
    
    lazy var screen = BookScreen(state: self)
    
    init(bookName: String, imageURLs: [String?] = [], description: String = "", genre: String? = nil, isbn: String = "", availableInstancesCount: Int = 0) {
        self.bookName = bookName
        self.imageURLs = imageURLs
        self.description = description
        self.genre = genre
        self.isbn = isbn
        self.availableInstancesCount = availableInstancesCount
    }
}

