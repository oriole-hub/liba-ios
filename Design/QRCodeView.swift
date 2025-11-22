//
//  QRCodeView.swift
//  Design
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - View

public struct QRCodeView: View {
    
    // MARK: Properties
    
    private let code: String
    private let size: CGFloat
    
    // MARK: Init
    
    public init(code: String, size: CGFloat = 200) {
        self.code = code
        self.size = size
    }
    
    // MARK: Body
    
    public var body: some View {
        Group {
            if let qrImage = generateQRCode(from: code) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: "qrcode")
                            .foregroundColor(.gray)
                            .font(.system(size: size * 0.3))
                    }
            }
        }
    }
    
    // MARK: Private methods
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        let scale = size / outputImage.extent.size.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Preview

#Preview {
    QRCodeView(code: "1234567890")
        .padding()
}

