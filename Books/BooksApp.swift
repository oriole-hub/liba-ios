//
//  BooksApp.swift
//  Books
//
//  Created by aristarh on 17.11.2025.
//

import SwiftUI

@main
struct BooksApp: App {
    
    private let appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            appState.screen
        }
    }
}
