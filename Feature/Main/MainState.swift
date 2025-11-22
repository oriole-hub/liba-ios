//
//  MainState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation

final class MainState: ObservableObject {
    @Published var searchText: String = ""
 
    lazy var screen = MainScreen(state: self)
}
