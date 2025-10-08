//
//  ViewExtensions.swift
//  Finansor
//
//  Created by Atakan İçel on 30.03.2025.
//

import Foundation
import SwiftUI
// MARK: - Text Field Extension (Login ekranı)

// Define a local text field style to avoid name conflicts
struct FinansorTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

extension TextField {
    func finansorStyle() -> some View {
        self.textFieldStyle(FinansorTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.bottom, 5)
            .frame(height: 50)
            .background(
                ZStack {
                    // Gölge
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.2))
                        .offset(y: 2)
                    
                    // Arkaplan
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.15))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - SecureField Extension (Şifreler için)
extension SecureField {
    func finansorStyle() -> some View {
        self.textFieldStyle(FinansorTextFieldStyle())
            .padding(.bottom, 5)
            .frame(height: 50)
            .background(
                ZStack {
                    // Gölge
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.2))
                        .offset(y: 2)
                    
                    // Arkaplan
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.15))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// Define a local button style to avoid name conflicts
struct FinansorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

//MARK: - Button Stlye
extension Button{
    func finansorFilledStyle() -> some View {
        self.buttonStyle(FinansorButtonStyle())
            .foregroundColor(.white)
            .padding()
            .background(
                ZStack {
                    // Gölge katmanı (arka derinlik hissi)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(FinansorColors.buttonLightBlue)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 4, y: 4)

                    // Işık yansıması katmanı (üstten gelen ışık efekti)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                // Hafif kenar ışığı
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
    
    func finansorOutlinedStyle() -> some View {
        self.foregroundColor(FinansorColors.buttonLightBlue)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}


extension View {
    // Klavyeyi gizleme methodu
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
