//
//  MainScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation
import AVFoundation

struct MainScreen: View {
    
    @StateObject var state: MainState
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if state.isLoading && state.books.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Button(action: {
                                let barcode = UserDefaults.group.userBarcode ?? ""
                                let fullName = UserDefaults.group.userFullName ?? ""
                                state.destination = .libraryCard(LibraryCardState(
                                    qrCode: barcode,
                                    holderName: fullName
                                ))
                            }) {
                                ReaderTicketView(bottomRightText: state.userFullName)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Array(state.books.enumerated()), id: \.element.id) { index, book in
                                    Button(action: {
                                        // Подсчитываем доступные экземпляры (статус "available")
                                        let availableCount = book.instances.filter { $0.status.lowercased() == "available" }.count
                                        
                                        state.destination = .book(BookState(
                                            bookName: book.title,
                                            imageURLs: book.urlPic != nil ? [book.urlPic] : [],
                                            description: book.description ?? "Описание книги отсутствует.",
                                            genre: book.genre,
                                            isbn: book.isbn,
                                            availableInstancesCount: availableCount
                                        ))
                                    }) {
                                        BookGridCell(imageURL: book.urlPic, bookName: book.title)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        // Загружаем следующую страницу, когда показываются последние элементы
                                        if index >= state.books.count - 3 && state.hasMoreBooks && !state.isLoadingMore {
                                            Task {
                                                await state.loadMoreBooks()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Индикатор загрузки дополнительных книг
                            if state.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(16)
                    }
                    .refreshable {
                        await state.loadBooks()
                    }
                }
            }
            .navigationTitle("Главная")
            .searchable(text: $state.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        state.showBarcodeScanner = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        state.destination = .profile(ProfileState())
                    }) {
                        Image(systemName: "person.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $state.showBarcodeScanner) {
                BarcodeScannerScreen(
                    state: BarcodeScannerState { bookState in
                        // Открываем страницу книги и закрываем сканер
                        state.destination = .book(bookState)
                        state.showBarcodeScanner = false
                    }
                )
            }
            .navigationDestination(item: $state.destination.book) { bookState in
                bookState.screen
            }
            .navigationDestination(item: $state.destination.libraryCard) { libraryCardState in
                libraryCardState.screen
            }
            .navigationDestination(item: $state.destination.profile) { profileState in
                profileState.screen
            }
            .onAppear {
                Task {
                    // Загружаем данные пользователя
                    await state.loadUserData()
                    // Загружаем книги, если список пуст
                    if state.books.isEmpty {
                        await state.loadBooks()
                    }
                }
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { state.errorMessage != nil },
                    set: { if !$0 { state.errorMessage = nil } }
                )
            ) {
                Button("OK") {
                    state.errorMessage = nil
                }
            } message: {
                if let errorMessage = state.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}
