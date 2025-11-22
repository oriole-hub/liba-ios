//
//  Code128BarcodeView.swift
//  Design
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - View

public struct Code128BarcodeView: View {
    
    // MARK: Properties
    
    private let code: String
    private let width: CGFloat
    private let height: CGFloat
    
    // MARK: Init
    
    public init(code: String, width: CGFloat = 200, height: CGFloat = 60) {
        self.code = code
        self.width = width
        self.height = height
    }
    
    // MARK: Body
    
    public var body: some View {
        Group {
            if let barcodeImage = generateCode128(from: code) {
                Image(uiImage: barcodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                    .overlay {
                        Image(systemName: "barcode")
                            .foregroundColor(.gray)
                            .font(.system(size: height * 0.3))
                    }
            }
        }
    }
    
    // MARK: Private methods
    
    private func generateCode128(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.code128BarcodeGenerator()
        
        let data = string.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        // Масштабируем изображение до нужного размера
        let scaleX = width / outputImage.extent.size.width
        let scaleY = height / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Preview

#Preview {
    Code128BarcodeView(code: "1234567890")
        .padding()
}

