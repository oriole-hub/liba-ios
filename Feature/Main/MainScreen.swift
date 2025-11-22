//
//  MainScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

struct MainScreen: View {
    
    @StateObject var state: MainState
    
    // Примерные данные для демонстрации
    private let sampleBooks: [(imageURL: String?, name: String)] = [
        (imageURL: "https://example.com/book1.jpg", name: "Война и мир"),
        (imageURL: "https://example.com/book2.jpg", name: "Преступление и наказание"),
        (imageURL: nil, name: "Мастер и Маргарита"),
        (imageURL: "https://example.com/book4.jpg", name: "Анна Каренина"),
        (imageURL: "https://example.com/book5.jpg", name: "Братья Карамазовы"),
        (imageURL: nil, name: "Идиот"),
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ReaderTicketView(bottomRightText: "ФАМИЛИЯ И.О.")
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(sampleBooks.enumerated()), id: \.offset) { index, book in
                            Button(action: {
                                // Действие при нажатии на книгу
                            }) {
                                BookGridCell(imageURL: book.imageURL, bookName: book.name)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Главная")
            .searchable(text: $state.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.fill")
                    }
                }
            }
        }
    }
}
