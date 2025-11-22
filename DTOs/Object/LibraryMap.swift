//
//  LibraryMap.swift
//  DTOs
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import MemberwiseInit
import SwiftUI

// MARK: - Model

public enum LibraryMap {
    public enum Responses {}
}

// MARK: - Responses

public extension LibraryMap.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct LibraryMapResponse: Codable {
        public let floors: [Floor]
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Floor: Identifiable, Codable {
        public let id: UUID
        public let title: String
        public let walls: [Wall]
        public let doors: [Door]
        public let furniture: [Furniture]
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Wall: Identifiable, Codable {
        public let id: UUID
        public let title: String
        public let position: Position
        public let size: Size
        public let color: ColorRGB?
        public let rotation: Double?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Door: Identifiable, Codable {
        public let id: UUID
        public let title: String
        public let position: Position
        public let size: Size
        public let color: ColorRGB?
        public let type: DoorType?
        public let rotation: Double?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Furniture: Identifiable, Codable {
        public let id: UUID
        public let title: String
        public let position: Position
        public let size: Size
        public let color: ColorRGB?
        public let type: FurnitureType?
        public let rotation: Double?
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Position: Codable {
        public let x: Double // Нормализованная координата 0.0-1.0
        public let y: Double // Нормализованная координата 0.0-1.0
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct Size: Codable {
        public let width: Double // Нормализованный размер 0.0-1.0
        public let height: Double // Нормализованный размер 0.0-1.0
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct ColorRGB: Codable {
        public let red: Double // 0.0-1.0
        public let green: Double // 0.0-1.0
        public let blue: Double // 0.0-1.0
        public let alpha: Double? // 0.0-1.0, по умолчанию 1.0
        
        public var swiftUIColor: SwiftUI.Color {
            SwiftUI.Color(
                red: red,
                green: green,
                blue: blue,
                opacity: alpha ?? 1.0
            )
        }
    }
    
    public enum DoorType: String, Codable {
        case single
        case double
        case sliding
        case revolving
    }
    
    public enum FurnitureType: String, Codable {
        case shelf
        case table
        case chair
        case desk
        case cabinet
        case sofa
        case other
    }
}

