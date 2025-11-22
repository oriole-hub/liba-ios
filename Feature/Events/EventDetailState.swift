//
//  EventDetailState.swift
//  Books
//
//  Created by aristarh on 16.11.2025.
//

import Foundation
import UIKit
import Dependencies
import SwiftNavigation

final class EventDetailState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.eventService) private var eventService
    
    lazy var screen = EventDetailScreen(state: self)
    
    @Published var event: Event.Responses.EventResponse
    @Published var isRegistered: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let notificationKey: String
    
    @Published var emailNotificationsEnabled: Bool {
        didSet {
            UserDefaults.group.set(emailNotificationsEnabled, forKey: notificationKey)
        }
    }
    
    // MARK: Init
    
    init(event: Event.Responses.EventResponse, isRegistered: Bool) {
        self.event = event
        self.isRegistered = isRegistered
        self.notificationKey = "event_notification_\(event.id.uuidString)"
        self.emailNotificationsEnabled = UserDefaults.group.bool(forKey: notificationKey)
    }
    
    // MARK: Actions
    
    @MainActor
    func loadEventDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedEvent = try await eventService.getEventDetail(eventId: event.id)
            self.event = updatedEvent
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func registerForEvent() async {
        guard !isRegistered else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await eventService.registerForEvent(eventId: event.id)
            self.isRegistered = true
            // Обновляем количество доступных мест
            await loadEventDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func cancelRegistration() async {
        guard isRegistered else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await eventService.cancelEventRegistration(eventId: event.id)
            self.isRegistered = false
            // Обновляем количество доступных мест
            await loadEventDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func shareEvent() {
        let text = "\(event.title)\n\(event.location)\n\(formatDate(event.date))"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

