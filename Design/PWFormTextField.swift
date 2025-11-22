//
//  PWFormTextField.swift
//  Design
//
//  Created by aristarh on 15.11.2025.
//

import SwiftUI
import Combine

public enum PWFormTextFieldState {
    case active
    case unactive
}

// MARK: - View

public struct PWFormTextField: View {
    
    // MARK: Properties
    
    public struct Action {
        public let title: String
        public let enabled: Bool
        public let action: () -> Void
        
        public init(title: String, enabled: Bool, action: @escaping () -> Void) {
            self.title = title
            self.enabled = enabled
            self.action = action
        }
    }
    
    public struct Config {
        public let title: String
        public let placeholder: String
        public let action: Action?
        
        public init(title: String, placeholder: String, action: Action? = nil) {
            self.title = title
            self.placeholder = placeholder
            self.action = action
        }
    }
    
    // MARK: State
    
    @Binding private var text: String
    @State private var state: PWFormTextFieldState = .unactive
    @State private var config: Config
    @FocusState private var isFocused: Bool
    
    // MARK: Computed Properties
    
    private var borderWidth: CGFloat {
        switch state {
        case .active: 2
        case .unactive: 1
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .active: .red
        case .unactive: .green
        }
    }
    
    private var textfieldVerticalPadding: CGFloat {
        switch state {
        case .active:
            18
        case .unactive:
            14
        }
    }
    
    // MARK: Init
    
    public init(text: Binding<String>, config: Config) {
        _text = text
        _config = State(initialValue: config)
    }
    
    // MARK: Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and Action Container
            HStack {
                Text(config.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.red)
                
                Spacer()
                
                if let action = config.action {
                    Button(action: action.action) {
                        Text(action.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accent)
                    }
                    .disabled(!action.enabled)
                }
            }
            
            // TextField Container
            TextField(config.placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, textfieldVerticalPadding)
                .background(.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    withAnimation(.easeInOut(duration: 0.14)) {
                        state = focused ? .active : .unactive
                    }
                }
        }
        .animation(.easeInOut(duration: 0.14), value: state)
    }
}
