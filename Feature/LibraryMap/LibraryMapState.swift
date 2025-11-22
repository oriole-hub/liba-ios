//
//  LibraryMapState.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import Foundation

final class LibraryMapState: ObservableObject {
    
    @Published var libraryMap: LibraryMap.Responses.LibraryMapResponse?
    @Published var selectedFloorIndex: Int = 0
    
    lazy var screen = LibraryMapScreen(state: self)
    
    init() {
        loadMap(from: "library_map_example")
    }
    
    func loadMap(from fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ Файл \(fileName).json не найден в Bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder.default
            libraryMap = try decoder.decode(LibraryMap.Responses.LibraryMapResponse.self, from: data)
        } catch {
            print("❌ Ошибка при парсинге JSON: \(error)")
        }
    }
    
    var currentFloor: LibraryMap.Responses.Floor? {
        guard let libraryMap = libraryMap,
              selectedFloorIndex >= 0,
              selectedFloorIndex < libraryMap.floors.count else {
            return nil
        }
        return libraryMap.floors[selectedFloorIndex]
    }
}
