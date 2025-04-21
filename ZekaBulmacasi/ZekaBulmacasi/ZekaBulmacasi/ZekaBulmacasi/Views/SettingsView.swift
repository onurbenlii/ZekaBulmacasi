// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject var game: GameModel
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            game.selectedTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Ayarlar")
                    .font(AppTypography.title)
                    .foregroundColor(game.selectedTheme.textColor)
                    .padding(.top, 50)

                VStack(spacing: 15) {
                    Text("Tema Seçimi")
                        .font(AppTypography.subtitle)
                        .foregroundColor(game.selectedTheme.textColor)

                    Picker("Tema", selection: Binding(
                        get: { game.selectedTheme },
                        set: { newTheme in
                            game.setTheme(newTheme)
                        }
                    )) {
                        Text("Açık").tag(Theme.light)
                        Text("Koyu").tag(Theme.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding()

                Spacer()

                Button(action: {
                    path.removeLast(path.count)
                }) {
                    Text("Ana Sayfaya Dön")
                        .navigationButtonStyle()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SettingsView(game: GameModel(), path: .constant(NavigationPath()))
}
