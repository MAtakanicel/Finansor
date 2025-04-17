//
//  AppColors.swift
//  Finansor
//
//  Created by Atakan İçel on 27.03.2025.
//

import Foundation
import SwiftUI

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
    struct AppColors {
        
        //Light Mode
        static let backgroundLight = Color(red: 0.96, green: 0.98, blue: 0.96) // #F5F9F6
        static let cardLight = Color.white
        static let textLight = Color.black
        static let secondaryTextLight = Color.gray.opacity(0.7)
        
        //Dark Mode
        static let backgroundDark = Color(red: 0.10, green: 0.15, blue: 0.20) // #1A2634
        static let cardDark = Color(red: 0.18, green: 0.24, blue: 0.31) // #2E3C4C
        static let textDark = Color.white
        static let secondaryTextDark = Color.gray.opacity(0.6)
        
        static let primaryBlue = Color(hex: "#1A73E8")
        static let primaryGreen = Color(red: 0.30, green: 0.69, blue: 0.31) // #4CAF50
        static let warningRed = Color(red: 1.0, green: 0.38, blue: 0.30) // #FF6150
        static let accentYellow = Color(red: 1.0, green: 0.76, blue: 0.03) // #FFC107
        
        static let income = Color(hex: "#28A745")
        static let expense = Color(hex: "#E53935")
        
        static let buttonLightBlue = Color(hex: "1a82f6")
    }

extension Color {
    static let backgroundDarkBlue = Color(red: 0.17, green: 0.17, blue: 0.22)
    static let backgroundLightBlue = Color(red: 0.15, green: 0.15, blue: 0.25)
    static let buttonlightGreen = Color(red: 30/255, green: 250/255, blue: 85/255)
    static let buttonGreen = Color(red: 39/255, green: 174/255, blue: 96/255)
}



extension Color {
    struct DefaultTheme {
        static let backgroundLight = Color(hex: "#F8F9FA")
        static let backgroundDark = Color(hex: "#121212")
        
        static let primary = Color(hex: "#1A73E8")
        static let income = Color(hex: "#34A853")
        static let expense = Color(hex: "#EA4335")
        
        static let textLight = Color(hex: "#202124")
        static let textDark = Color(hex: "#EDEDED")
    }
}

extension Color {
    struct RetroTheme {
        static let background = Color(hex: "#FDF6F0")
        
        static let primary = Color(hex: "#F4A261")
        static let income = Color(hex: "#2A9D8F")
        static let expense = Color(hex: "#E76F51")
        
        static let text = Color(hex: "#264653")
    }
}

extension Color {
    struct CalmGreenTheme {
        static let background = Color(hex: "#EFFAF1")
        
        static let primary = Color(hex: "#2D6A4F")
        static let accent = Color(hex: "#40916C")
        static let secondary = Color(hex: "#95D5B2")
        
        static let income = Color(hex: "#2D6A4F")
        static let expense = Color(hex: "#E76F51")
        
        static let text = Color(hex: "#1B4332")
    }
}

extension Color {
    struct FinansorTheme {
        // Dark Mode
        static let darkBackground = Color(hex: "#0E1116")
                static let darkCard = Color(hex: "#263646") // güncellenmiş açık kart rengi
                static let darkIncome = Color(hex: "#30D158")
                static let darkExpense = Color(hex: "#FF453A")
                static let darkText = Color(hex: "#F0F3F5")
                
                // Light Mode
                static let lightBackground = Color(hex: "#FAF6F2")
                static let lightCard = Color(hex: "#FFFFFF")
                static let lightIncome = Color(hex: "#28A745")
                static let lightExpense = Color(hex: "#E53935")
                static let lightText = Color(hex: "#1E1E1E")
    }
}
