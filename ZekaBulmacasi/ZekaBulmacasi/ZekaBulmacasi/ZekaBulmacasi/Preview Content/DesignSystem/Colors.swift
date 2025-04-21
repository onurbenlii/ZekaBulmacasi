// DesignSystem/Colors.swift
import SwiftUI

struct AppColors {
    static let primary = Color(appHex: "#007AFF") // Modern mavi (butonlar için)
    static let secondary = Color(appHex: "#34C759") // Yeşil (Hint butonu için)
    static let disabled = Color(appHex: "#C7C7CC") // Gri (devre dışı butonlar)
    static let error = Color(appHex: "#FF3B30") // Kırmızı (hata mesajları)
    static let textPrimary = Color(appHex: "#1C2526") // Koyu gri (ana metin rengi)
    static let background = Color(appHex: "#F2F2F7") // Açık gri (genel arka plan)
    static let cellBackground = Color(appHex: "#E6E6FA") // Lavanta (tahta kareleri)
    static let boardBackground = Color(appHex: "#FFFFFF") // Beyaz (tahta arka planı)
    static let headerBackground = Color(appHex: "#FFFFFF") // Beyaz (header arka planı)
    static let footerBackground = Color(appHex: "#FFFFFF") // Beyaz (footer arka planı)
}

extension Color {
    init(appHex: String) {
        let hex = appHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
