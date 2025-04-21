// DesignSystem/Buttons.swift
import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.body)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(width: 110)
            .background(AppColors.primary)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

struct SecondaryButtonModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        content
            .font(AppTypography.body)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(width: 120)
            .background(enabled ? AppColors.secondary : AppColors.disabled)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

struct TertiaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.body)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(width: 90)
            .background(AppColors.disabled)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

struct NavigationButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.body)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(width: 200)
            .background(Color.gray)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonModifier())
    }

    func secondaryButtonStyle(enabled: Bool) -> some View {
        self.modifier(SecondaryButtonModifier(enabled: enabled))
    }

    func tertiaryButtonStyle() -> some View {
        self.modifier(TertiaryButtonModifier())
    }

    func navigationButtonStyle() -> some View {
        self.modifier(NavigationButtonModifier())
    }
}
