//
//  ErrorResponse.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//


// MARK: - ErrorResponse

public struct ErrorResponse: Error, Decodable {
    public let error: Bool
    public let reason: String
}
