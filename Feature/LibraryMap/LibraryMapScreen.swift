//
//  LibraryMapScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

struct LibraryMapScreen: View {
    
    @StateObject var state: LibraryMapState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let libraryMap = state.libraryMap, !libraryMap.floors.isEmpty {
                    // Picker для выбора этажа
                    Picker("Этаж", selection: $state.selectedFloorIndex) {
                        ForEach(Array(libraryMap.floors.enumerated()), id: \.element.id) { index, floor in
                            Text(floor.title).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    Spacer()
                    
                    // Карта этажа
                    if let floor = state.currentFloor {
                        GeometryReader { geometry in
                            ZStack {
                                // Фон
                                Color.white
                                
                                // Отрисовка стен
                                ForEach(floor.walls) { wall in
                                    WallView(wall: wall, containerSize: geometry.size)
                                }
                                
                                // Отрисовка дверей
                                ForEach(floor.doors) { door in
                                    DoorView(door: door, containerSize: geometry.size)
                                }
                                
                                // Отрисовка мебели
                                ForEach(floor.furniture) { furniture in
                                    FurnitureView(furniture: furniture, containerSize: geometry.size)
                                }
                            }
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding()
                    }
                    Spacer()
                } else {
                    VStack {
                        Text("Карта не загружена")
                            .foregroundColor(.secondary)
                        Text("Проверьте наличие файла library_map_example.json")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Карта библиотеки")
        }
    }
}

// MARK: - Wall View

struct WallView: View {
    let wall: LibraryMap.Responses.Wall
    let containerSize: CGSize
    
    var body: some View {
        let x = wall.position.x * containerSize.width
        let y = wall.position.y * containerSize.height
        let width = wall.size.width * containerSize.width
        let height = wall.size.height * containerSize.height
        let centerX = x + width / 2
        let centerY = y + height / 2
        let rotation = wall.rotation ?? 0
        
        Rectangle()
            .fill(wall.color?.swiftUIColor ?? Color.gray)
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation), anchor: .center)
            .position(x: centerX, y: centerY)
    }
}

// MARK: - Door View

struct DoorView: View {
    let door: LibraryMap.Responses.Door
    let containerSize: CGSize
    
    private let minSizeForTitle: Double = 0.08 // Минимальный размер стороны для отображения текста
    
    var body: some View {
        let x = door.position.x * containerSize.width
        let y = door.position.y * containerSize.height
        let width = door.size.width * containerSize.width
        let height = door.size.height * containerSize.height
        let centerX = x + width / 2
        let centerY = y + height / 2
        let rotation = door.rotation ?? 0
        let normalizedWidth = door.size.width
        let normalizedHeight = door.size.height
        let shouldShowTitle = normalizedWidth > minSizeForTitle || normalizedHeight > minSizeForTitle
        
        ZStack {
            Rectangle()
                .fill(door.color?.swiftUIColor ?? Color.brown)
                .frame(width: width, height: height)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                )
            
            if shouldShowTitle {
                ObjectTitleView(
                    title: door.title,
                    objectWidth: width,
                    objectHeight: height
                )
            }
        }
        .rotationEffect(.degrees(rotation), anchor: .center)
        .position(x: centerX, y: centerY)
    }
}

// MARK: - Furniture View

struct FurnitureView: View {
    let furniture: LibraryMap.Responses.Furniture
    let containerSize: CGSize
    
    private let minSizeForTitle: Double = 0.08 // Минимальный размер стороны для отображения текста
    
    var body: some View {
        let x = furniture.position.x * containerSize.width
        let y = furniture.position.y * containerSize.height
        let width = furniture.size.width * containerSize.width
        let height = furniture.size.height * containerSize.height
        let centerX = x + width / 2
        let centerY = y + height / 2
        let rotation = furniture.rotation ?? 0
        let normalizedWidth = furniture.size.width
        let normalizedHeight = furniture.size.height
        let shouldShowTitle = normalizedWidth > minSizeForTitle || normalizedHeight > minSizeForTitle
        
        ZStack {
            Rectangle()
                .fill(furniture.color?.swiftUIColor ?? Color.blue)
                .frame(width: width, height: height)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 0.5)
                )
            
            if shouldShowTitle {
                ObjectTitleView(
                    title: furniture.title,
                    objectWidth: width,
                    objectHeight: height
                )
            }
        }
        .rotationEffect(.degrees(rotation), anchor: .center)
        .position(x: centerX, y: centerY)
    }
}

// MARK: - Object Title View

struct ObjectTitleView: View {
    let title: String
    let objectWidth: CGFloat
    let objectHeight: CGFloat
    
    private let paddingRatio: CGFloat = 0.15 // Отступ от краев (15%)
    
    var body: some View {
        let availableWidth = objectWidth * (1 - 2 * paddingRatio)
        let availableHeight = objectHeight * (1 - 2 * paddingRatio)
        
        Text(title)
            .font(.system(size: calculateFontSize(availableWidth: availableWidth, availableHeight: availableHeight)))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.5)
            .frame(width: availableWidth, height: availableHeight)
            .fixedSize(horizontal: false, vertical: false)
    }
    
    private func calculateFontSize(availableWidth: CGFloat, availableHeight: CGFloat) -> CGFloat {
        // Начальный размер шрифта
        let baseFontSize: CGFloat = 12
        // Минимальный размер шрифта
        let minFontSize: CGFloat = 8
        // Максимальный размер шрифта
        let maxFontSize: CGFloat = 16
        
        // Вычисляем размер на основе доступного пространства
        let widthBasedSize = availableWidth / CGFloat(title.count) * 1.2
        let heightBasedSize = availableHeight * 0.6
        
        let calculatedSize = min(widthBasedSize, heightBasedSize)
        
        // Ограничиваем размер шрифта
        return max(minFontSize, min(maxFontSize, calculatedSize))
    }
}
