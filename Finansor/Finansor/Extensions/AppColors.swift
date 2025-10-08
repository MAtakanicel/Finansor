//
//  AppColors.swift
//  Finansor
//
//  Created by Atakan İçel on 27.03.2025.
//

import Foundation
import SwiftUI

// Hex uzantısı
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// Main color palette for the app - single source of truth
struct AppColorsDefinition {
    // Light Mode
    static let backgroundLight = Color(red: 0.96, green: 0.98, blue: 0.96) // #F5F9F6
    static let cardLight = Color.white
    static let textLight = Color.black
    static let secondaryTextLight = Color.gray.opacity(0.7)
    
    // Dark Mode
    static let backgroundDark = Color(red: 0.10, green: 0.15, blue: 0.20) // #1A2634
    static let cardDark = Color(red: 0.18, green: 0.24, blue: 0.31) // #2E3C4C
    static let textDark = Color.white
    static let secondaryTextDark = Color.gray.opacity(0.6)
    
    // Accent Colors
    static let primaryBlue = Color(hex: "#1A73E8")
    static let accentBlue = Color(hex: "#2196F3")
    static let primaryGreen = Color(red: 0.30, green: 0.69, blue: 0.31) // #4CAF50
    static let warningRed = Color(red: 1.0, green: 0.38, blue: 0.30) // #FF6150
    static let accentYellow = Color(red: 1.0, green: 0.76, blue: 0.03) // #FFC107
    
    // Financial Colors
    static let income = Color(hex: "#28A745")
    static let expense = Color(hex: "#E53935")
    
    // UI Elements
    static let buttonLightBlue = Color(hex: "1a82f6")
    
    // Backward compatibility
    struct BackwardCompatibility {
        static let backgroundDarkBlue = Color(red: 0.17, green: 0.17, blue: 0.22)
        static let backgroundLightBlue = Color(red: 0.15, green: 0.15, blue: 0.25)
        static let buttonlightGreen = Color(red: 30/255, green: 250/255, blue: 85/255)
        static let buttonGreen = Color(red: 39/255, green: 174/255, blue: 96/255)
    }
}

// Create type aliases to maintain compatibility with existing code
typealias AppColors = AppColorsDefinition
typealias FinansorColors = AppColorsDefinition
