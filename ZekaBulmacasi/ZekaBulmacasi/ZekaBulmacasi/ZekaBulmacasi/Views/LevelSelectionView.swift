// LevelSelectionView.swift
import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var game: GameModel
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            game.selectedTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Bölüm Seç")
                    .font(AppTypography.title)
                    .foregroundColor(game.selectedTheme.textColor)
                    .padding(.top, 50)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        ForEach(1...game.levelCount, id: \.self) { level in
                            Button(action: {
                                if level <= game.currentLevel {
                                    game.selectedLevel = level
                                    game.setupLevel()
                                    path.append("GameView")
                                }
                            }) {
                                Text("\(level)")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(game.isLevelCompleted(level) ? Color(appHex: "#32CD32") : (level <= game.currentLevel ? Color(appHex: "#D3D3D3") : Color(appHex: "#D3D3D3").opacity(0.5)))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(level > game.currentLevel)
                        }
                    }
                    .padding()
                }

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
    LevelSelectionView(game: GameModel(), path: .constant(NavigationPath()))
}
