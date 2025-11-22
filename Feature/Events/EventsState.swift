//
//  EventsState.swift
//  Books
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class EventsState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.eventService) private var eventService
    
    lazy var screen = EventsScreen(state: self)
    
    @Published var events: [Event.Responses.EventResponse] = []
    @Published var registeredEventIds: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    private var currentSkip: Int = 0
    private let limit: Int = 20
    @Published var hasMoreEvents: Bool = true
    
    // MARK: Filters
    
    enum StatusFilter: String, CaseIterable {
        case all = "Все"
        case planned = "Запланированные"
        case cancelled = "Отмененные"
        case completed = "Завершенные"
    }
    
    enum DateFilter: String, CaseIterable {
        case all = "Все"
        case today = "Сегодня"
        case thisWeek = "На этой неделе"
        case thisMonth = "В этом месяце"
    }
    
    enum RegistrationFilter: String, CaseIterable {
        case all = "Все"
        case registered = "Зарегистрированные"
        case notRegistered = "Незарегистрированные"
    }
    
    @Published var selectedStatusFilter: StatusFilter = .all
    @Published var selectedDateFilter: DateFilter = .all
    @Published var selectedRegistrationFilter: RegistrationFilter = .all
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case eventDetail(EventDetailState)
    }
    
    @Published var destination: Destination?
    
    // MARK: Computed Properties
    
    var filteredEvents: [Event.Responses.EventResponse] {
        var filtered = events
        
        // Фильтр по статусу
        if selectedStatusFilter != .all {
            filtered = filtered.filter { event in
                switch selectedStatusFilter {
                case .all:
                    return true
                case .planned:
                    return event.status == .planned
                case .cancelled:
                    return event.status == .cancelled
                case .completed:
                    return event.status == .completed
                }
            }
        }
        
        // Фильтр по дате
        if selectedDateFilter != .all {
            let now = Date()
            let calendar = Calendar.current
            
            filtered = filtered.filter { event in
                switch selectedDateFilter {
                case .all:
                    return true
                case .today:
                    return calendar.isDateInToday(event.date)
                case .thisWeek:
                    return calendar.isDate(event.date, equalTo: now, toGranularity: .weekOfYear)
                case .thisMonth:
                    return calendar.isDate(event.date, equalTo: now, toGranularity: .month)
                }
            }
        }
        
        // Фильтр по регистрации
        if selectedRegistrationFilter != .all {
            filtered = filtered.filter { event in
                let isRegistered = registeredEventIds.contains(event.id)
                switch selectedRegistrationFilter {
                case .all:
                    return true
                case .registered:
                    return isRegistered
                case .notRegistered:
                    return !isRegistered
                }
            }
        }
        
        return filtered
    }
    
    func isRegistered(eventId: UUID) -> Bool {
        return registeredEventIds.contains(eventId)
    }
    
    // MARK: Init
    
    init() {}
    
    // MARK: Actions
    
    @MainActor
    func loadEvents() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentSkip = 0
        
        do {
            async let eventsTask = eventService.listUpcomingEvents(skip: 0, limit: limit)
            async let registrationsTask = eventService.getMyEventRegistrations(includePast: false)
            
            let (loadedEvents, registrations) = try await (eventsTask, registrationsTask)
            
            self.events = loadedEvents
            self.registeredEventIds = Set(registrations.map { $0.id })
            self.currentSkip = loadedEvents.count
            self.hasMoreEvents = loadedEvents.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreEvents() async {
        guard !isLoadingMore, !isLoading, hasMoreEvents else { return }
        
        isLoadingMore = true
        
        do {
            let loadedEvents = try await eventService.listUpcomingEvents(skip: currentSkip, limit: limit)
            events.append(contentsOf: loadedEvents)
            currentSkip += loadedEvents.count
            hasMoreEvents = loadedEvents.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    @MainActor
    func refreshRegistrations() async {
        do {
            let registrations = try await eventService.getMyEventRegistrations(includePast: false)
            self.registeredEventIds = Set(registrations.map { $0.id })
        } catch {
            // Не показываем ошибку, просто не обновляем регистрации
            print("Failed to refresh registrations: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func navigateToEventDetail(event: Event.Responses.EventResponse) {
        let eventDetailState = EventDetailState(event: event, isRegistered: isRegistered(eventId: event.id))
        destination = .eventDetail(eventDetailState)
    }
}

