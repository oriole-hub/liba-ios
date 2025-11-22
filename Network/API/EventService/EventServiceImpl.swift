//
//  EventServiceImpl.swift
//  RequestKit
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Moya
import Dependencies

// MARK: - Dependencies

extension DependencyValues {
    
    var eventService: any EventServiceProtocol {
        get { self[EventServiceKey.self] }
        set { self[EventServiceKey.self] = newValue }
    }
    
    enum EventServiceKey: DependencyKey {
        public static let liveValue: EventServiceProtocol = EventServiceImpl(
            requestService: RequestService<PWNetworkTarget.EventTarget>()
        )
    }
}

// MARK: - Network target

public extension PWNetworkTarget {
    
    enum EventTarget: PWTargetType {
        
        // MARK: Endpoints
        
        case createEvent(parameters: Event.Parameters.EventCreate)
        case listUpcomingEvents(skip: Int?, limit: Int?)
        case getEventDetail(eventId: UUID)
        case updateEvent(eventId: UUID, parameters: Event.Parameters.EventUpdate)
        case getAllEventsAdmin(skip: Int?, limit: Int?)
        case registerForEvent(eventId: UUID)
        case cancelEventRegistration(eventId: UUID)
        case getMyEventRegistrations(includePast: Bool?)
        
        // MARK: Target
        
        public var baseURL: URL {
            serverURL
        }
        
        public var path: String {
            switch self {
            case .createEvent: "/events"
            case .listUpcomingEvents: "/events"
            case .getEventDetail(let eventId): "/events/\(eventId.uuidString)"
            case .updateEvent(let eventId, _): "/events/\(eventId.uuidString)"
            case .getAllEventsAdmin: "/events/admin/all"
            case .registerForEvent(let eventId): "/events/\(eventId.uuidString)/register"
            case .cancelEventRegistration(let eventId): "/events/\(eventId.uuidString)/register"
            case .getMyEventRegistrations: "/events/my/registrations"
            }
        }
        
        public var method: Moya.Method {
            switch self {
            case .createEvent: .post
            case .listUpcomingEvents: .get
            case .getEventDetail: .get
            case .updateEvent: .put
            case .getAllEventsAdmin: .get
            case .registerForEvent: .post
            case .cancelEventRegistration: .delete
            case .getMyEventRegistrations: .get
            }
        }
        
        public var task: Moya.Task {
            let encoder = JSONEncoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
            
            switch self {
            case .createEvent(let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .listUpcomingEvents(let skip, let limit):
                var parameters: [String: Any] = [:]
                if let skip = skip {
                    parameters["skip"] = skip
                }
                if let limit = limit {
                    parameters["limit"] = limit
                }
                return .requestParameters(
                    parameters: parameters,
                    encoding: URLEncoding.queryString
                )
            case .getEventDetail:
                return .requestPlain
            case .updateEvent(_, let parameters):
                do {
                    let data = try parameters.encoded(using: encoder)
                    return .requestData(data)
                } catch {
                    return .requestData(Data())
                }
            case .getAllEventsAdmin(let skip, let limit):
                var parameters: [String: Any] = [:]
                if let skip = skip {
                    parameters["skip"] = skip
                }
                if let limit = limit {
                    parameters["limit"] = limit
                }
                return .requestParameters(
                    parameters: parameters,
                    encoding: URLEncoding.queryString
                )
            case .registerForEvent:
                return .requestPlain
            case .cancelEventRegistration:
                return .requestPlain
            case .getMyEventRegistrations(let includePast):
                var parameters: [String: Any] = [:]
                if let includePast = includePast {
                    parameters["include_past"] = includePast
                }
                return .requestParameters(
                    parameters: parameters,
                    encoding: URLEncoding.queryString
                )
            }
        }
        
        public var needsAuth: Bool {
            switch self {
            case .createEvent: true
            case .listUpcomingEvents: false
            case .getEventDetail: false
            case .updateEvent: true
            case .getAllEventsAdmin: true
            case .registerForEvent: true
            case .cancelEventRegistration: true
            case .getMyEventRegistrations: true
            }
        }
    }
}

// MARK: - Real service

public final class EventServiceImpl: EventServiceProtocol {
    
    // MARK: Properties
    
    private let requestService: RequestService<PWNetworkTarget.EventTarget>
    
    // MARK: Init
    
    public init(requestService: RequestService<PWNetworkTarget.EventTarget>) {
        self.requestService = requestService
    }
    
    // MARK: Public methods
    
    public func createEvent(parameters: Event.Parameters.EventCreate) async throws -> Event.Responses.EventResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.createEvent(parameters: parameters))
            .map(Event.Responses.EventResponse.self, using: decoder)
        
        return response
    }
    
    public func listUpcomingEvents(skip: Int?, limit: Int?) async throws -> [Event.Responses.EventResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.listUpcomingEvents(skip: skip, limit: limit))
            .map([Event.Responses.EventResponse].self, using: decoder)
        
        return response
    }
    
    public func getEventDetail(eventId: UUID) async throws -> Event.Responses.EventResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getEventDetail(eventId: eventId))
            .map(Event.Responses.EventResponse.self, using: decoder)
        
        return response
    }
    
    public func updateEvent(eventId: UUID, parameters: Event.Parameters.EventUpdate) async throws -> Event.Responses.EventResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.updateEvent(eventId: eventId, parameters: parameters))
            .map(Event.Responses.EventResponse.self, using: decoder)
        
        return response
    }
    
    public func getAllEventsAdmin(skip: Int?, limit: Int?) async throws -> [Event.Responses.EventResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getAllEventsAdmin(skip: skip, limit: limit))
            .map([Event.Responses.EventResponse].self, using: decoder)
        
        return response
    }
    
    public func registerForEvent(eventId: UUID) async throws -> Event.Responses.EventRegistrationResponse {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.registerForEvent(eventId: eventId))
            .map(Event.Responses.EventRegistrationResponse.self, using: decoder)
        
        return response
    }
    
    public func cancelEventRegistration(eventId: UUID) async throws {
        _ = try await requestService
            .asyncRequest(.cancelEventRegistration(eventId: eventId))
    }
    
    public func getMyEventRegistrations(includePast: Bool?) async throws -> [Event.Responses.EventResponse] {
        let decoder = JSONDecoder.with(.roundedDate(.millisecondsAndSeconds), .snakeCase)
        let response = try await requestService
            .asyncRequest(.getMyEventRegistrations(includePast: includePast))
            .map([Event.Responses.EventResponse].self, using: decoder)
        
        return response
    }
}


