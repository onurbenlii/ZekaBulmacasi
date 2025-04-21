// StatsView.swift
import SwiftUI

struct StatsView: View {
    @ObservedObject var game: GameModel
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            game.selectedTheme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("İstatistikler")
                    .font(AppTypography.title)
                    .foregroundColor(game.selectedTheme.textColor)
                    .padding(.top, 50)

                ScrollView {
                    VStack(spacing: 10) {
                        // Tamamlanan Bölüm Sayısı
                        Text("Tamamlanan Bölüm Sayısı: \(game.completedLevelCount())")
                            .font(AppTypography.subtitle)
                            .foregroundColor(game.selectedTheme.textColor)

                        // Toplam Oyun Süresi
                        Text("Toplam Oyun Süresi: \(Int(game.totalPlayTime / 60)) dk")
                            .font(AppTypography.subtitle)
                            .foregroundColor(game.selectedTheme.textColor)

                        // Her Seviyenin Tamamlama Süresi
                        Text("Seviye Tamamlama Süreleri")
                            .font(AppTypography.subtitle)
                            .foregroundColor(game.selectedTheme.textColor)
                            .padding(.top, 20)

                        ForEach(1...game.levelCount, id: \.self) { level in
                            if game.isLevelCompleted(level),
                               let time = game.getCompletionTime(forLevel: level) {
                                HStack {
                                    Text("Bölüm \(level):")
                                        .font(AppTypography.body)
                                        .foregroundColor(game.selectedTheme.textColor)
                                        .frame(width: 100, alignment: .leading)
                                    Text("\(String(format: "%.1f", time)) sn")
                                        .font(AppTypography.body)
                                        .foregroundColor(game.selectedTheme.textColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
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
    StatsView(game: GameModel(), path: .constant(NavigationPath()))
}
