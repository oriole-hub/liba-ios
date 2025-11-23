//
//  ReversedReaderTicketView.swift
//  Design
//
//  Created by aristarh on 21.11.2025.
//

import SwiftUI
import PassKit
import UIKit
import ColorfulX

// MARK: - View

public struct ReversedReaderTicketView: View {
    
    // MARK: Properties
    
    private let holderName: String
    private let qrCode: String
    private let pass: PKPass?
    
    // MARK: Init
    
    public init(holderName: String, qrCode: String, pass: PKPass? = nil) {
        self.holderName = holderName
        self.qrCode = qrCode
        self.pass = pass
    }
    
    // MARK: Body
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            ColorfulView(color: .aurora, speed: .constant(1.25))
                .cornerRadius(14)
            VStack {
                HStack {
                    Text(holderName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Code128BarcodeView(code: qrCode, width: 260, height: 80)
                    Spacer()
                }
                Spacer()
                if PKAddPassesViewController.canAddPasses() {
                    HStack {
                        Spacer()
                        PKAddPassButtonRepresentable(pass: pass)
                            .frame(height: 30)
                        Spacer()
                    }
                }
            }
            .padding(16)
            
//            // Кнопка добавления в кошелек в верхнем правом углу
//            VStack(alignment: .trailing) {
//                HStack {
//                    Spacer()
////                    if PKAddPassesViewController.canAddPasses() {
////                        PKAddPassButtonRepresentable(pass: pass)
////                            .frame(height: 30)
////                            .padding(.top, 16)
////                            .padding(.trailing, 16)
////                    }
//                }
//                Spacer()
//            }
        }
        .aspectRatio(1.68, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - PKAddPassButton Representable

struct PKAddPassButtonRepresentable: UIViewRepresentable {
    let pass: PKPass?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(pass: pass)
    }
    
    func makeUIView(context: Context) -> PKAddPassButton {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.isEnabled = pass != nil
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.addPassButtonTapped),
            for: .touchUpInside
        )
        return button
    }
    
    func updateUIView(_ uiView: PKAddPassButton, context: Context) {
        uiView.isEnabled = pass != nil
        context.coordinator.pass = pass
    }
    
    class Coordinator: NSObject {
        var pass: PKPass?
        
        init(pass: PKPass?) {
            self.pass = pass
        }
        
        @objc func addPassButtonTapped() {
            guard let pass = pass,
                  let addPassesViewController = PKAddPassesViewController(pass: pass) else {
                return
            }
            
            // Находим корневой view controller для презентации
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(addPassesViewController, animated: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ReversedReaderTicketView(
        holderName: "ИВАНОВ И.И.",
        qrCode: "1234567890",
        pass: nil
    )
    .padding()
}

