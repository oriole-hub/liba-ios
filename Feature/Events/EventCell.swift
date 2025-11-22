//
//  EventCell.swift
//  Books
//
//  Created by aristarh on 16.11.2025.
//

import SwiftUI

struct EventCell: View {
    let event: Event.Responses.EventResponse
    let dateFormatter: DateFormatter
    let isRegistered: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                titleSection
                infoSection
                availabilitySection
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var titleSection: some View {
        Text(event.title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.primary)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            dateRow
            locationRow
        }
    }
    
    @ViewBuilder
    private var dateRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text("Дата: \(dateFormatter.string(from: event.date))")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var locationRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text("Место: \(event.location)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private var availabilitySection: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "person.2")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("Доступно мест: \(event.availableSeats) из \(event.totalSeats)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isRegistered {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    Text("Зарегистрирован")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
        }
    }
}

