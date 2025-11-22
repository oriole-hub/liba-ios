//
//  MainScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

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
                    Button(action: {
                        state.destination = .libraryCard(LibraryCardState())
                    }) {
                        ReaderTicketView(bottomRightText: "ФАМИЛИЯ И.О.")
                    }
                    .buttonStyle(PlainButtonStyle())
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(sampleBooks.enumerated()), id: \.offset) { index, book in
                            Button(action: {
                                state.destination = .book(BookState(
                                    bookName: book.name,
                                    imageURLs: book.imageURL != nil ? [book.imageURL] : [],
                                    description: "Это описание книги \"\(book.name)\". Здесь будет размещена подробная информация о книге, её содержании и особенностях."
                                ))
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
            .navigationDestination(item: $state.destination.book) { bookState in
                bookState.screen
            }
            .navigationDestination(item: $state.destination.libraryCard) { libraryCardState in
                libraryCardState.screen
            }
        }
    }
}
