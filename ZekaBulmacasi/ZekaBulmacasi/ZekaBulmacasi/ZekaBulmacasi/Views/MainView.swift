// MainView.swift
import SwiftUI

@main
struct ZekaBulmacasiApp: App {
    @StateObject private var game = GameModel()
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                MainView(path: $path)
                    .environmentObject(game)
                    .navigationDestination(for: String.self) { destination in
                        switch destination {
                        case "LevelSelectionView":
                            LevelSelectionView(game: game, path: $path)
                        case "HowToPlayView":
                            HowToPlayView(path: $path)
                        case "GameView":
                            GameView(game: game, path: $path)
                        case "StatsView":
                            StatsView(game: game, path: $path)
                        case "SettingsView":
                            SettingsView(game: game, path: $path)
                        default:
                            EmptyView()
                        }
                    }
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var game: GameModel
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            game.selectedTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Zeka Bulmacası")
                    .font(AppTypography.title)
                    .foregroundColor(game.selectedTheme.textColor)
                    .padding(.top, 50)

                Spacer()

                Button(action: {
                    path.append("LevelSelectionView")
                }) {
                    Text("Oyna")
                        .primaryButtonStyle()
                }

                Button(action: {
                    path.append("HowToPlayView")
                }) {
                    Text("Nasıl Oynanır")
                        .primaryButtonStyle()
                }

                Button(action: {
                    path.append("StatsView")
                }) {
                    Text("İstatistikler")
                        .primaryButtonStyle()
                }

                Button(action: {
                    path.append("SettingsView")
                }) {
                    Text("Ayarlar")
                        .primaryButtonStyle()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainView(path: .constant(NavigationPath()))
        .environmentObject(GameModel())
}
