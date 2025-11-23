//
//  RecommendationServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol RecommendationServiceProtocol {
    
    func getRecommendations(skip: Int?, limit: Int?) async throws -> [Book.Responses.BookDetailResponse]
}

