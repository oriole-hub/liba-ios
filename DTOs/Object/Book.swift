//
//  Book.swift
//  DTOs
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Book {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension Book.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BookCreate: Codable {
        public let title: String
        public let author: String
        public let isbn: String
        public let description: String?
        public let genre: String?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BookInstanceCreate: Codable {
        public let inventoryNumber: String
        public let storageLocation: String
    }
}

// MARK: - Responses

public extension Book.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BookResponse: Codable {
        public let id: UUID
        public let title: String
        public let description: String?
        public let genre: String?
        public let author: String
        public let isbn: String
        public let createdAt: Date
        public let updatedAt: Date
        public let instanceCount: Int
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BookDetailResponse: Codable {
        public let id: UUID
        public let title: String
        public let description: String?
        public let genre: String?
        public let author: String
        public let isbn: String
        public let createdAt: Date
        public let updatedAt: Date
        public let instances: [BookInstanceResponse]
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct BookInstanceResponse: Codable {
        public let id: UUID
        public let bookId: UUID
        public let inventoryNumber: String
        public let storageLocation: String
        public let status: String
        public let createdAt: Date
        public let updatedAt: Date
    }
}

