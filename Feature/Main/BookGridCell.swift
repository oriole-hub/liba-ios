//
//  BookGridCell.swift
//  Books
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI

struct BookGridCell: View {
    
    let imageURL: String?
    let bookName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "book.closed")
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .aspectRatio(0.7, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxWidth: .infinity)
            Text(bookName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .aspectRatio(0.7, contentMode: .fit)
    }
}

