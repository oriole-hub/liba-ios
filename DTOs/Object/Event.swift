//
//  Event.swift
//  DTOs
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import MemberwiseInit

// MARK: - Model

public enum Event {
    public enum Parameters {}
    public enum Responses {}
}

// MARK: - Event Status

public enum EventStatus: String, Codable {
    case planned
    case cancelled
    case completed
}

// MARK: - Parameters

public extension Event.Parameters {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct EventCreate: Codable {
        public let title: String
        public let description: String?
        public let date: Date
        public let location: String
        public let totalSeats: Int
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct EventUpdate: Codable {
        public let title: String?
        public let description: String?
        public let date: Date?
        public let location: String?
        public let totalSeats: Int?
        public let status: EventStatus?
    }
}

// MARK: - Responses

public extension Event.Responses {
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct EventResponse: Codable {
        public let id: UUID
        public let title: String
        public let description: String?
        public let date: Date
        public let location: String
        public let totalSeats: Int
        public let availableSeats: Int
        public let status: EventStatus
        public let createdAt: Date
        public let updatedAt: Date
    }
    
    @MemberwiseInit(.public, _optionalsDefaultNil: true)
    struct EventRegistrationResponse: Codable {
        public let id: UUID
        public let eventId: UUID
        public let userId: UUID
        public let registeredAt: Date
    }
}


