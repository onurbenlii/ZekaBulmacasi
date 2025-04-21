// GameView.swift
import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @Binding var path: NavigationPath
    @State private var showLevelComplete: Bool = false
    @State private var showAdPrompt: Bool = false
    @State private var displayedLevel: Int
    @State private var temporaryErrorMessage: String = ""
    @State private var completedLevel: Int?
    @State private var timer: Timer? = nil // Süre sayacı için Timer
    @State private var elapsedTime: Double = 0.0 // Geçen süre (saniye cinsinden)
    @State private var isProcessingButton: Bool = false // Buton çift tıklamasını önlemek için

    init(game: GameModel, path: Binding<NavigationPath>) {
        self.game = game
        self._path = path
        self._displayedLevel = State(initialValue: game.selectedLevel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 35) {
                // Header: Ana sayfa butonu, jeton sayısı, bölüm ismi
                HStack {
                    Button(action: {
                        stopTimer() // Süre sayacını durdur
                        game.endSession()
                        path.removeLast(path.count)
                    }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary)
                    }
                    Spacer()
                    // Jeton simgesi ve sayısı
                    HStack(spacing: 6) {
                        Image(systemName: "centsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#0000FF")) // Altın sarısı renk
                        Text("\(game.coins)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(game.selectedTheme.headerBackgroundColor.opacity(0.8))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    Spacer()
                    Text("Bölüm \(displayedLevel)")
                        .font(AppTypography.subtitle)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.leading, 100.0)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(game.selectedTheme.headerBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Süre Sayacı Gösterimi
                Text("Süre: \(String(format: "%.1f", elapsedTime)) sn")
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.textPrimary)

                // Orta Kısım: Oyun tahtası
                Spacer()
                BoardView(game: game)
                    .padding(.horizontal, 16)
                Spacer(minLength: 40) // Tahtanın altında sabit bir boşluk bırak

                // Footer: "Kalan Tahmin Hakkı" ve Butonlar
                VStack(spacing: 8) {
                    Text("Kalan Tahmin Hakkı: \(game.remainingGuesses)")
                        .font(AppTypography.subheadline)
                        .foregroundColor(game.selectedTheme.secondaryTextColor)

                    HStack(spacing: 12) {
                        // Geri Al Butonu
                        Button(action: {
                            game.undo()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 18))
                                Text("Geri Al")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                game.isHistoryEmpty() ? Color.gray : Color.blue
                            )
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                        .disabled(game.isHistoryEmpty())

                        // İpucu Butonu
                        Button(action: {
                            game.hint()
                            // Yalnızca hata mesajları için pop-up göster
                            if game.errorMessage == "Jetonunuz bitti! Reklam izleyerek jeton kazanabilirsiniz." ||
                               game.errorMessage == "Boş kare yok!" {
                                withAnimation {
                                    temporaryErrorMessage = game.errorMessage
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        self.temporaryErrorMessage = ""
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 18))
                                Text("İpucu")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.yellow)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }

                        // Tamamla Butonu
                        Button(action: {
                            // Çift tıklamayı önlemek için koruma
                            guard !isProcessingButton else {
                                print("Çift tıklama engellendi!")
                                return
                            }
                            isProcessingButton = true
                            print("Tamamla butonuna tıklandı!")

                            if game.levelCompleted {
                                stopTimer() // Süre sayacını durdur
                                displayedLevel = game.selectedLevel
                                completedLevel = game.selectedLevel
                                game.checkBoard(completionTime: elapsedTime) // Süreyi GameModel’e kaydet
                                showLevelComplete = true
                                print("showLevelComplete set to true, pop-up should appear")
                            } else if game.coins == 0 && !game.isPremium {
                                showAdPrompt = true
                            } else {
                                game.checkBoard()
                                // Hata mesajını geçici olarak göster, ancak "Boş kare yok!" mesajını atla
                                if game.errorMessage != "Boş kare yok!" {
                                    withAnimation {
                                        temporaryErrorMessage = game.errorMessage
                                    }
                                    // 1 saniye sonra mesajı sıfırla
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        withAnimation {
                                            self.temporaryErrorMessage = ""
                                        }
                                    }
                                }
                            }
                            // İşlem tamamlandı, koruma bayrağını sıfırla
                            isProcessingButton = false
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18))
                                Text("Tamamla")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .background(game.selectedTheme.footerBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
            }
            .background(game.selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)

            // Hata mesajı pop-up
            if !temporaryErrorMessage.isEmpty {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                VStack(spacing: 15) {
                    Text(temporaryErrorMessage)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.error)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .padding()
                .background(
                    game.selectedTheme.popupBackgroundColor
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .transition(.opacity)
                .onAppear {
                    print("Hata mesajı pop-up olarak göründü: \(temporaryErrorMessage)")
                }
            }

            // Pop-up: Seviye tamamlandı
            if showLevelComplete {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                LevelCompleteView(
                    level: completedLevel ?? game.selectedLevel,
                    onNextLevel: {
                        let nextLevel = (completedLevel ?? game.selectedLevel) + 1
                        if !game.isLevelCompleted(nextLevel) && nextLevel <= game.levelCount {
                            game.selectedLevel = nextLevel
                            game.proceedToNextLevel()
                            showLevelComplete = false
                            game.endSession()
                            elapsedTime = 0.0 // Süreyi sıfırla
                            startTimer() // Yeni seviye için sayacı başlat
                            displayedLevel = game.selectedLevel
                            path.append("GameView")
                        } else {
                            stopTimer()
                            game.endSession()
                            showLevelComplete = false
                            path.removeLast(path.count)
                            path.append("LevelSelectionView")
                        }
                    },
                    onSelectLevel: {
                        stopTimer()
                        game.endSession()
                        showLevelComplete = false
                        path.removeLast(path.count)
                        path.append("LevelSelectionView")
                    },
                    onHome: {
                        stopTimer()
                        game.endSession()
                        showLevelComplete = false
                        path.removeLast(path.count)
                    }
                )
                .padding()
                .background(
                    game.selectedTheme.popupBackgroundColor
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .onAppear {
                    print("LevelCompleteView pop-up appeared!")
                }
            }

            // Pop-up: Jeton bitti
            if showAdPrompt {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                VStack(spacing: 15) {
                    Text("Jetonunuz Bitti!")
                        .font(AppTypography.subtitle)
                        .foregroundColor(game.selectedTheme.textColor)
                        .padding(.bottom, 5)
                    Text("Reklam izleyerek 1 jeton kazanabilir veya premium satın alarak sınırsız oynayabilirsiniz.")
                        .font(AppTypography.body)
                        .foregroundColor(game.selectedTheme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: {
                        game.watchAdForCoin()
                        showAdPrompt = false
                    }) {
                        Text("Reklam İzle")
                            .primaryButtonStyle()
                    }
                    Button(action: {
                        game.purchasePremium()
                        showAdPrompt = false
                    }) {
                        Text("Premium Satın Al")
                            .primaryButtonStyle()
                    }
                    Button(action: {
                        showAdPrompt = false
                    }) {
                        Text("Kapat")
                            .navigationButtonStyle()
                    }
                }
                .padding(20)
                .background(
                    game.selectedTheme.popupBackgroundColor
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            }
        }
        .onAppear {
            game.startSession()
            startTimer() // Oyun başladığında sayacı başlat
        }
    }

    private func startTimer() {
        elapsedTime = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// Color için hex kodunu desteklemek için bir extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GameView(game: GameModel(), path: .constant(NavigationPath()))
}
