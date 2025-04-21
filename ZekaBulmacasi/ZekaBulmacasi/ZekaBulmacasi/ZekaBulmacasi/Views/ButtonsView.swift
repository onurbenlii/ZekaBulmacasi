// ButtonsView.swift
import SwiftUI

struct ButtonsView: View {
    @ObservedObject var game: GameModel
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    game.undo()
                }
            }) {
                Text("Undo")
                    .tertiaryButtonStyle()
            }

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    game.hint()
                }
            }) {
                Text("Hint (\(game.coins > 0 || game.isPremium ? "1 🪙" : "Jeton Yok"))")
                    .secondaryButtonStyle(enabled: game.coins > 0 || game.isPremium)
            }
            .disabled(game.coins == 0 && !game.isPremium)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    print("Tamamla butonuna tıklandı!") // Hata ayıklama için log
                    game.checkBoard() // Tahtayı kontrol et
                    print("checkBoard çalıştı, levelCompleted: \(game.levelCompleted)")
                    onComplete() // Geri çağrıyı tetikle
                }
            }) {
                Text("Tamamla")
                    .primaryButtonStyle()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ButtonsView(game: GameModel(), onComplete: {})
}
