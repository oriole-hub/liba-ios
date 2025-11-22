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
    
    lazy var screen = BookScreen(state: self)
    
    init(bookName: String, imageURLs: [String?] = [], description: String = "") {
        self.bookName = bookName
        self.imageURLs = imageURLs
        self.description = description
    }
}

