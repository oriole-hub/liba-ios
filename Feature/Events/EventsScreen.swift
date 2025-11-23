//
//  EventsScreen.swift
//  Books
//
//  Created by aristarh on 16.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct EventsScreen: View {
    
    @StateObject var state: EventsState
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filtersSection
                contentView
            }
            .navigationTitle("События")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await state.loadEvents()
            }
            .onAppear {
                if state.events.isEmpty {
                    Task {
                        await state.loadEvents()
                    }
                } else {
                    // Обновляем регистрации при возврате на экран
                    Task {
                        await state.refreshRegistrations()
                    }
                }
            }
            .navigationDestination(item: $state.destination.eventDetail) { eventDetailState in
                eventDetailState.screen
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
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var filtersSection: some View {
        HStack(spacing: 12) {
            // Фильтр по статусу
            Menu {
                ForEach(EventsState.StatusFilter.allCases, id: \.self) { filter in
                    Button {
                        state.selectedStatusFilter = filter
                    } label: {
                        HStack {
                            Text(filter.rawValue)
                            if state.selectedStatusFilter == filter {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 14))
                    Text(state.selectedStatusFilter.rawValue)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Фильтр по дате
            Menu {
                ForEach(EventsState.DateFilter.allCases, id: \.self) { filter in
                    Button {
                        state.selectedDateFilter = filter
                    } label: {
                        HStack {
                            Text(filter.rawValue)
                            if state.selectedDateFilter == filter {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(state.selectedDateFilter.rawValue)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Фильтр по регистрации
            Menu {
                ForEach(EventsState.RegistrationFilter.allCases, id: \.self) { filter in
                    Button {
                        state.selectedRegistrationFilter = filter
                    } label: {
                        HStack {
                            Text(filter.rawValue)
                            if state.selectedRegistrationFilter == filter {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 14))
                    Text(state.selectedRegistrationFilter.rawValue)
                        .font(.system(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if state.isLoading && state.events.isEmpty {
            loadingView
        } else if state.filteredEvents.isEmpty {
            emptyStateView
        } else {
            eventsListView
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        ProgressView()
        Spacer()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        Spacer()
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Нет событий")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        Spacer()
    }
    
    @ViewBuilder
    private var eventsListView: some View {
        List {
            ForEach(Array(state.filteredEvents.enumerated()), id: \.element.id) { index, event in
                EventCell(
                    event: event,
                    dateFormatter: dateFormatter,
                    isRegistered: state.isRegistered(eventId: event.id),
                    onTap: {
                        state.navigateToEventDetail(event: event)
                    }
                )
                .onAppear {
                    // Загружаем следующую страницу, когда показываются последние элементы
                    if index >= state.filteredEvents.count - 3 && state.hasMoreEvents && !state.isLoadingMore {
                        Task {
                            await state.loadMoreEvents()
                        }
                    }
                }
            }
            
            // Индикатор загрузки дополнительных событий
            if state.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            }
        }
        .listStyle(.insetGrouped)
    }
}

