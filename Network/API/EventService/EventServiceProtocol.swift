//
//  EventServiceProtocol.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation

// MARK: - Protocol

public protocol EventServiceProtocol {
    
    func createEvent(parameters: Event.Parameters.EventCreate) async throws -> Event.Responses.EventResponse
    
    func listUpcomingEvents(skip: Int?, limit: Int?) async throws -> [Event.Responses.EventResponse]
    
    func getEventDetail(eventId: UUID) async throws -> Event.Responses.EventResponse
    
    func updateEvent(eventId: UUID, parameters: Event.Parameters.EventUpdate) async throws -> Event.Responses.EventResponse
    
    func getAllEventsAdmin(skip: Int?, limit: Int?) async throws -> [Event.Responses.EventResponse]
    
    func registerForEvent(eventId: UUID) async throws -> Event.Responses.EventRegistrationResponse
    
    func cancelEventRegistration(eventId: UUID) async throws
    
    func getMyEventRegistrations(includePast: Bool?) async throws -> [Event.Responses.EventResponse]
}


