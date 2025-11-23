//
//  Recommendation.swift
//  DTOs
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Recommendation {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Parameters

public extension Recommendation.Parameters {
    
    @MemberwiseInit(.public)
    struct RecommendationRequest: Codable {
        public let skip: Int?
        public let limit: Int?
    }
}

// MARK: - Responses

public extension Recommendation.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct RecommendationResponse: Codable {
        public let id: UUID
        public let bookId: UUID
        public let title: String
        public let author: String
        public let isbn: String
        public let description: String?
        public let genre: String?
        public let urlPic: String?
        public let reason: String?
        public let score: Double?
        public let createdAt: Date
    }
}

