//
//  EventDetailScreen.swift
//  Books
//
//  Created by aristarh on 16.11.2025.
//

import SwiftUI
import SwiftUINavigation

struct EventDetailScreen: View {
    
    @StateObject var state: EventDetailState
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    titleSection
                    descriptionSection
                }
                dateSection
                locationSection
                availabilitySection
                statusSection
                actionsSection
                notificationsSection
            }
            .padding()
        }
        .navigationTitle("Событие")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    state.shareEvent()
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            Task {
                await state.loadEventDetails()
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
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var titleSection: some View {
        Text(state.event.title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var descriptionSection: some View {
        if let description = state.event.description, !description.isEmpty {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Описание")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
//            }
        }
    }
    
    @ViewBuilder
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                Text("Дата и время")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Text(dateFormatter.string(from: state.event.date))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
    }
    
    @ViewBuilder
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                Text("Место проведения")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Text(state.event.location)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
    }
    
    @ViewBuilder
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                Text("Доступность")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Text("Доступно мест: \(state.event.availableSeats) из \(state.event.totalSeats)")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
    }
    
    @ViewBuilder
    private var statusSection: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.system(size: 20))
                .foregroundColor(statusColor)
            Text("Статус: \(statusText)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(statusColor)
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        Button(action: {
            Task {
                if state.isRegistered {
                    await state.cancelRegistration()
                } else {
                    await state.registerForEvent()
                }
            }
        }) {
            HStack {
                if state.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: state.isRegistered ? "xmark.circle" : "checkmark.circle")
                    Text(state.isRegistered ? "Отменить регистрацию" : "Зарегистрироваться")
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(state.isRegistered ? Color.red : Color.accentColor)
            .cornerRadius(12)
        }
        .disabled(state.isLoading)
    }
    
    @ViewBuilder
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                Text("Email-уведомления")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $state.emailNotificationsEnabled)
            }
            Text("Получать уведомления на email о событии")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var statusText: String {
        switch state.event.status {
        case .planned:
            return "Запланировано"
        case .cancelled:
            return "Отменено"
        case .completed:
            return "Завершено"
        }
    }
    
    private var statusIcon: String {
        switch state.event.status {
        case .planned:
            return "clock"
        case .cancelled:
            return "xmark.circle"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch state.event.status {
        case .planned:
            return .blue
        case .cancelled:
            return .red
        case .completed:
            return .green
        }
    }
}

