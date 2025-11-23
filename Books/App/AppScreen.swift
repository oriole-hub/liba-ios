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
                if #available(iOS 18.0, *) {
                    tabViewWithNewAPI
                } else {
                    tabViewWithOldAPI
                }
            }
        }
        .onAppear {
            if Keychain.app.accessToken != nil {
                state.destination = .mainTab()
            }
        }
    }
    
    @available(iOS 18.0, *)
    private var tabViewWithNewAPI: some View {
        TabView(selection: $state.tabSelection) {
            Tab("Главная", systemImage: state.tabSelection == .main ? "house.fill" : "house", value: AppState.TabSelection.main) {
                state.mainState.screen
            }
            
            Tab("Мои книги", systemImage: state.tabSelection == .loans ? "book.fill" : "book", value: AppState.TabSelection.loans) {
                state.loansState.screen
            }
            
            Tab("События", systemImage: state.tabSelection == .events ? "calendar" : "calendar", value: AppState.TabSelection.events) {
                state.eventsState.screen
            }
            
            Tab("Профиль", systemImage: state.tabSelection == .profile ? "person.fill" : "person", value: AppState.TabSelection.profile) {
                state.profileState.screen
            }
        }
    }
    
    private var tabViewWithOldAPI: some View {
        TabView(selection: $state.tabSelection) {
            state.mainState.screen
                .tag(AppState.TabSelection.main)
                .tabItem {
                    Label("Главная", systemImage: state.tabSelection == .main ? "house.fill" : "house")
                }
            
            state.eventsState.screen
                .tag(AppState.TabSelection.events)
                .tabItem {
                    Label("События", systemImage: state.tabSelection == .events ? "calendar" : "calendar")
                }
            
            state.loansState.screen
                .tag(AppState.TabSelection.loans)
                .tabItem {
                    Label("Мои книги", systemImage: state.tabSelection == .loans ? "book.fill" : "book")
                }
            
            state.profileState.screen
                .tag(AppState.TabSelection.profile)
                .tabItem {
                    Label("Профиль", systemImage: state.tabSelection == .profile ? "person.fill" : "person")
                }
        }
    }
}
