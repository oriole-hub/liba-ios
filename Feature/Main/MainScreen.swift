//
//  MainScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation
import AVFoundation
import PassKit

// PreferenceKey для отслеживания позиций секций
struct SectionOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct MainScreen: View {
    
    @StateObject var state: MainState
    @State private var stickyHeader: String? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    private var cardBarcode: String {
        let barcode = UserDefaults.group.userBarcode ?? ""
        return barcode.isEmpty ? "0000000000" : barcode
    }
    
    private var cardHolderName: String {
        let name = state.userFullName
        return name.isEmpty ? "ИМЯ ДЕРЖАТЕЛЯ" : name
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if state.isLoading && state.books.isEmpty {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            FlipCardView(isFlipped: $state.isCardFlipped) {
                                ReaderTicketView(bottomRightText: state.userFullName)
                            } back: {
                                ReversedReaderTicketView(
                                    holderName: cardHolderName,
                                    qrCode: cardBarcode,
                                    pass: state.walletPass
                                )
                            }
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    state.isCardFlipped.toggle()
                                }
                            }
                            
                            // Заголовок "Рекомендации" с отслеживанием позиции
                            SectionHeaderView(title: "Рекомендации", id: "recommendations")
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.preference(
                                            key: SectionOffsetPreferenceKey.self,
                                            value: ["recommendations": geometry.frame(in: .named("scroll")).minY]
                                        )
                                    }
                                )
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 16) {
                                    if state.isLoadingRecommendations && state.recommendations.isEmpty {
                                        ProgressView()
                                            .padding()
                                    } else if state.recommendations.isEmpty {
                                        Text("Рекомендации отсутствуют")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(state.recommendations, id: \.id) { recommendation in
                                            Button(action: {
                                                // Подсчитываем доступные экземпляры (статус "available")
                                                let availableCount = recommendation.instances.filter { $0.status.lowercased() == "available" }.count
                                                state.destination = .book(BookState(
                                                    bookName: recommendation.title,
                                                    imageURLs: recommendation.urlPic != nil ? [recommendation.urlPic] : [],
                                                    description: recommendation.description ?? "Описание книги отсутствует.",
                                                    genre: recommendation.genre,
                                                    isbn: recommendation.isbn,
                                                    availableInstancesCount: availableCount
                                                ))
                                            }) {
                                                BookGridCell(imageURL: recommendation.urlPic, bookName: recommendation.title)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .frame(height: 310)
                            
                            // Заголовок "Каталог" с отслеживанием позиции
                            SectionHeaderView(title: "Каталог", id: "catalog")
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.preference(
                                            key: SectionOffsetPreferenceKey.self,
                                            value: ["catalog": geometry.frame(in: .named("scroll")).minY]
                                        )
                                    }
                                )
                            
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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(SectionOffsetPreferenceKey.self) { offsets in
                        updateStickyHeader(offsets: offsets)
                    }
                    .refreshable {
                        await state.loadRecommendations()
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
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if let stickyHeader = stickyHeader {
                    VStack(spacing: 0) {
                        SectionHeaderView(title: stickyHeader == "recommendations" ? "Рекомендации" : "Каталог", id: stickyHeader + "_sticky")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemBackground))
                        Divider()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: stickyHeader)
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
            .sheet(isPresented: $state.showAddToWallet) {
                AddToWalletView(barcode: cardBarcode, holderName: cardHolderName)
            }
            .navigationDestination(item: $state.destination.book) { bookState in
                bookState.screen
            }
            .onAppear {
                Task {
                    // Загружаем данные пользователя
                    await state.loadUserData()
                    // Загружаем рекомендации, если список пуст
                    if state.recommendations.isEmpty {
                        await state.loadRecommendations()
                    }
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
    
    private func updateStickyHeader(offsets: [String: CGFloat]) {
        guard let recommendationsOffset = offsets["recommendations"],
              let catalogOffset = offsets["catalog"] else {
            stickyHeader = nil
            return
        }
        
        // Пороговое значение для определения, когда заголовок должен стать sticky
        // Когда заголовок прокручивается выше видимой области (minY становится отрицательным),
        // он должен стать sticky. Используем небольшой порог для более плавного переключения
        let threshold: CGFloat = 0
        
        // Определяем, какой заголовок должен быть закреплен
        // Приоритет отдаем тому заголовку, который прокручен выше и находится ближе к текущей позиции
        if catalogOffset < threshold {
            // "Каталог" прокручен выше порога - показываем его
            stickyHeader = "catalog"
        } else if recommendationsOffset < threshold {
            // "Рекомендации" прокручен выше порога, но "Каталог" еще нет - показываем "Рекомендации"
            stickyHeader = "recommendations"
        } else {
            // Ни один заголовок еще не достиг порога
            stickyHeader = nil
        }
    }
}

// Компонент для заголовка секции
struct SectionHeaderView: View {
    let title: String
    let id: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
}
