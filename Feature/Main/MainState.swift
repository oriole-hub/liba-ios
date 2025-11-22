//
//  MainState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation
import SwiftNavigation

final class MainState: ObservableObject {
    @Published var searchText: String = ""
    
    // MARK: Navigation
    
    @CasePathable
    enum Destination {
        case book(BookState)
        case libraryCard(LibraryCardState)
    }
    
    @Published var destination: Destination?
 
    lazy var screen = MainScreen(state: self)
}
