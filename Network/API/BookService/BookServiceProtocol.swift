//
//  BookServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol BookServiceProtocol {
    
    func createBook(parameters: Book.Parameters.BookCreate) async throws -> Book.Responses.BookResponse
    
    func getAllBooks(skip: Int?, limit: Int?) async throws -> [Book.Responses.BookDetailResponse]
    
    func getBookByISBN(isbn: String) async throws -> Book.Responses.BookDetailResponse
    
    func addBookInstance(bookId: UUID, parameters: Book.Parameters.BookInstanceCreate) async throws -> Book.Responses.BookInstanceResponse
    
    func searchBooks(parameters: Book.Parameters.BookSearchRequest, skip: Int?, limit: Int?) async throws -> [Book.Responses.BookDetailResponse]
}

