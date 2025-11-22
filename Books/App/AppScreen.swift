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
                }
                //        case .none:
                //            EmptyView()
            }
        }
        .onAppear {
            if Keychain.app.accessToken != nil {
                state.destination = .mainTab()
            }
        }
    }
}
