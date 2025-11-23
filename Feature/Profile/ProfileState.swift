//
//  ProfileState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import Dependencies
import SwiftNavigation

final class ProfileState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.authService) private var authService
    
    lazy var screen = ProfileScreen(state: self)
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case libraryMap(LibraryMapState)
    }
    
    @Published var destination: Destination?
    
    // MARK: Init
    
    init() {}
    
    // MARK: Actions
    
    @MainActor
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.logout()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

