//
//  Validation.swift
//  DTOs
//
//  Created by aristarh on 12.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Validation {
    public enum Responses {}
}

// MARK: - Responses

public extension Validation.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct HTTPValidationError: Codable {
        public let detail: [ValidationError]
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct ValidationError: Codable {
        public let loc: [ValidationErrorLocation]
        public let msg: String
        public let type: String
    }
    
    public enum ValidationErrorLocation: Codable {
        case string(String)
        case integer(Int)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let intValue = try? container.decode(Int.self) {
                self = .integer(intValue)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "ValidationErrorLocation must be either String or Int")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .integer(let value):
                try container.encode(value)
            }
        }
    }
}

