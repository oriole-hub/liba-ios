//
//  Token.swift
//  DTOs
//
//  Created by aristarh on 12.11.2025.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public, _optionalsDefaultNil: true)
public struct Token: Codable, Hashable, Equatable {
    public var value: String
    public var expiration: Date
}

