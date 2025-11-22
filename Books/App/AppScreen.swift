//
//  AppScreen.swift
//  Books
//
//  Created by aristarh on 17.11.2025.
//

import SwiftUI
import KeychainAccess

struct AppScreen: View {
    
    @StateObject var state: AppState
    
    var body: some View {
        Group {
            switch state.destination {
            case .auth:
                state.loginState.screen
            case .mainTab:
                TabView(selection: $state.tabSelection) {
                    state.mainState.screen
                        .tag(AppState.TabSelection.main)
                        .tabItem {
                            Label("Главная", systemImage: state.tabSelection == .main ? "house.fill" : "house")
                        }
                    state.libraryMapState.screen
                        .tag(AppState.TabSelection.libraryMap)
                        .tabItem {
                            Label("Карта", systemImage: state.tabSelection == .libraryMap ? "map.fill" : "map")
                        }
                    state.loansState.screen
                        .tag(AppState.TabSelection.loans)
                        .tabItem {
                            Label("Мои книги", systemImage: state.tabSelection == .loans ? "book.fill" : "book")
                        }
                    state.eventsState.screen
                        .tag(AppState.TabSelection.events)
                        .tabItem {
                            Label("События", systemImage: state.tabSelection == .events ? "calendar.fill" : "calendar")
                        }
                }
            }
        }
        .onAppear {
            if Keychain.app.accessToken != nil {
                state.destination = .mainTab()
            }
        }
    }
}
