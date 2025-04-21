// DesignSystem/Themes.swift
import SwiftUI

enum Theme: String {
    case light
    case dark

    var backgroundColor: Color {
        switch self {
        case .light:
            return AppColors.background
        case .dark:
            return Color(appHex: "#1C2526")
        }
    }

    var textColor: Color {
        switch self {
        case .light:
            return AppColors.textPrimary
        case .dark:
            return Color.white
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .light:
            return AppColors.textPrimary.opacity(0.7)
        case .dark:
            return Color.white.opacity(0.7)
        }
    }

    var cellColor: Color {
        switch self {
        case .light:
            return AppColors.cellBackground
        case .dark:
            return Color(appHex: "#4A4A4A")
        }
    }

    var cellBorderColor: Color {
        switch self {
        case .light:
            return Color.black.opacity(0.1)
        case .dark:
            return Color.white.opacity(0.1)
        }
    }

    var boardBackgroundColor: Color {
        switch self {
        case .light:
            return AppColors.boardBackground
        case .dark:
            return Color(appHex: "#2A2A2A")
        }
    }

    var popupBackgroundColor: Color {
        switch self {
        case .light:
            return Color(appHex: "#FFFFFF")
        case .dark:
            return Color(appHex: "#2A2A2A")
        }
    }

    var headerBackgroundColor: Color {
        switch self {
        case .light:
            return AppColors.headerBackground
        case .dark:
            return Color(appHex: "#2A2A2A")
        }
    }

    var footerBackgroundColor: Color {
        switch self {
        case .light:
            return AppColors.footerBackground
        case .dark:
            return Color(appHex: "#2A2A2A")
        }
    }
}
