//
//  CustomTextFileds.swift
//  Finansor
//
//  Created by Atakan İçel on 30.03.2025.
//

import Foundation
import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

struct StepIndicator: View {
    var currentStep: Int
    var totalSteps: Int = 3
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(step <= currentStep ? AppColors.accentYellow : Color.gray.opacity(0.5))
            }
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    // Ana renk + gölge
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.accentYellow)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 4, y: 4)
                    
                    // Üst parlaklık efekti
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.2), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .foregroundColor(AppColors.buttonLightBlue)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // basıldığında hafif küçülür
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


#Preview {
    VStack(spacing: 20) {
        TextField("Test Field", text: .constant(""))
            .textFieldStyle(CustomTextFieldStyle())
        
        StepIndicator(currentStep: 3)
    }
    .padding()
    .background(AppColors.backgroundDark)
    
    VStack(spacing:20){
        
        Button(action: {}){
            Text("Test Button")
                .buttonStyle(CustomButtonStyle())
            
        }
                    
                
        
        .frame(width: 200, height: 50)
        
    } .background(AppColors.backgroundDark)
        .frame(width: 200, height: 200)
}
