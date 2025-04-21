// LevelCompleteView.swift
import SwiftUI

struct LevelCompleteView: View {
    let level: Int
    let onNextLevel: () -> Void
    let onSelectLevel: () -> Void
    let onHome: () -> Void
    let showNextLevelButton: Bool

    init(level: Int, onNextLevel: @escaping () -> Void, onSelectLevel: @escaping () -> Void, onHome: @escaping () -> Void, showNextLevelButton: Bool = true) {
        self.level = level
        self.onNextLevel = onNextLevel
        self.onSelectLevel = onSelectLevel
        self.onHome = onHome
        self.showNextLevelButton = showNextLevelButton
    }

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.secondary)
                .padding(.bottom, 5)
            Text("Tebrikler! Bölüm \(level) Tamamlandı!")
                .font(AppTypography.subtitle)
                .foregroundColor(.black)
                .padding(.bottom, 10)

            if showNextLevelButton {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onNextLevel()
                    }
                }) {
                    Text("Bir Sonraki Bölüm")
                        .primaryButtonStyle()
                }
            }

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onSelectLevel()
                }
            }) {
                Text("Bölüm Seç")
                    .primaryButtonStyle()
            }

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    onHome()
                }
            }) {
                Text("Ana Sayfaya Dön")
                    .navigationButtonStyle()
            }
        }
    }
}

#Preview {
    LevelCompleteView(level: 1, onNextLevel: {}, onSelectLevel: {}, onHome: {})
}
