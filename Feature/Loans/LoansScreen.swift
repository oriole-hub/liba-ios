//
//  LoansScreen.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct LoansScreen: View {
    
    @StateObject var state: LoansState
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterPicker
                contentView
            }
            .navigationTitle("Мои книги")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await state.loadLoans()
            }
            .onAppear {
                if state.loans.isEmpty {
                    Task {
                        await state.loadLoans()
                    }
                }
            }
            .navigationDestination(item: $state.destination.book) { bookState in
                bookState.screen
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
    private var filterPicker: some View {
        Picker("Фильтр", selection: $state.selectedFilter) {
            ForEach(LoansState.FilterType.allCases, id: \.self) { filterType in
                Text(filterType.rawValue).tag(filterType)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: state.selectedFilter) { _ in
            // Фильтрация происходит автоматически через computed property
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if state.isLoading && state.loans.isEmpty {
            loadingView
        } else if state.filteredAndGroupedLoans.isEmpty {
            emptyStateView
        } else {
            loansListView
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
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Нет займов")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        Spacer()
    }
    
    @ViewBuilder
    private var loansListView: some View {
        List {
            ForEach(Array(state.filteredAndGroupedLoans.enumerated()), id: \.offset) { _, group in
                Section(header: Text(group.0)) {
                    ForEach(group.1, id: \.id) { loan in
                        LoanCell(
                            loan: loan,
                            dateFormatter: dateFormatter,
                            onTap: {
                                Task {
                                    await state.navigateToBook(loan: loan)
                                }
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Loan Cell

struct LoanCell: View {
    let loan: Loan.Responses.LoanDetailResponse
    let dateFormatter: DateFormatter
    let onTap: () -> Void
    
    private var isActive: Bool {
        loan.returnedAt == nil && loan.status.lowercased() != "returned"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                bookInfoSection
                datesSection
                statusSection
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var bookInfoSection: some View {
        if let bookTitle = loan.bookTitle, !bookTitle.isEmpty {
            Text(bookTitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        
        if let bookAuthor = loan.bookAuthor, !bookAuthor.isEmpty {
            Text(bookAuthor)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        
        if let inventoryNumber = loan.inventoryNumber, !inventoryNumber.isEmpty {
            HStack(spacing: 4) {
                Image(systemName: "number")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("Инвентарный номер: \(inventoryNumber)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            reservedDateRow
            issuedDateRow
            dueDateOrReturnedDateRow
        }
    }
    
    @ViewBuilder
    private var reservedDateRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text("Зарезервировано: \(dateFormatter.string(from: loan.reservedAt))")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var issuedDateRow: some View {
        if let issuedAt = loan.issuedAt {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                Text("Выдано: \(dateFormatter.string(from: issuedAt))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var dueDateOrReturnedDateRow: some View {
        if isActive {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("Срок возврата: \(dateFormatter.string(from: loan.dueDate))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        } else if let returnedAt = loan.returnedAt {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                Text("Возвращено: \(dateFormatter.string(from: returnedAt))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var statusSection: some View {
        HStack(spacing: 4) {
            Image(systemName: isActive ? "book.fill" : "book.closed.fill")
                .font(.system(size: 12))
                .foregroundColor(isActive ? .blue : .gray)
            Text("Статус: \(loan.status)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .blue : .gray)
        }
    }
}

