//
//  AppState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import SwiftNavigation
import Combine
import Dependencies

final class AppState: ObservableObject {
    
    // MARK: Properties
    
    @Dependency(\.authService) private var authService
    
    lazy var loginState = LoginState()
    lazy var screen = AppScreen(state: self)
    lazy var mainState = MainState()
    lazy var libraryMapState = LibraryMapState()
    lazy var loansState = LoansState()
    lazy var eventsState = EventsState()
    
    private var cancellables = Set<AnyCancellable>()
    
    enum TabSelection: String {
        case main
        case libraryMap
        case loans
        case events
    }
    
    @Published var tabSelection: TabSelection = .main
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case auth(String = "auth")
        case mainTab(String = "mainTab")
    }
    
    @Published var destination: Destination = .auth()
    
    // MARK: Init
    
    init() {
        setupAuthListener()
    }
    
    // MARK: Private methods
    
    private func setupAuthListener() {
        authService.userLoggedInPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.destination = value ? .mainTab() : .auth()
            }
            .store(in: &cancellables)
    }
}
