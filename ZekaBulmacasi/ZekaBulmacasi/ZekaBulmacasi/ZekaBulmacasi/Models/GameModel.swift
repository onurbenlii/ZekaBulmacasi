// GameModel.swift
import Foundation
import SwiftUI

// Level türünü tanımlayalım
struct Level: Codable {
    let level: Int
    let size: Int
    let initialGrid: [[String]]
    let signs: [SignData]
    let solution: [[String]]

    struct SignData: Codable {
        let from: [Int]
        let to: [Int]
        let type: String
    }
}

class GameModel: ObservableObject {
    @Published var board: Board
    @Published var coins: Int
    @Published var currentLevel: Int
    @Published var selectedLevel: Int
    @Published var remainingGuesses: Int
    @Published var errorMessage: String
    @Published var levelCompleted: Bool
    @Published var isPremium: Bool
    @Published var selectedTheme: Theme
    @Published var totalPlayTime: TimeInterval
    private var history: [((Int, Int), Symbol)]
    private var solution: [[Symbol]]
    private var levels: [Level]
    private var sessionStartTime: Date?
    private var completedLevels: Set<Int>
    private var completionTimes: [Int: Double] // Seviye bazında tamamlama süreleri (saniye)

    init() {
        self.board = Board(size: 6)
        self.solution = Array(repeating: Array(repeating: .empty, count: 6), count: 6)
        self.history = []
        self.levels = []
        self.levelCompleted = false
        self.errorMessage = ""
        self.isPremium = false
        self.coins = 0
        self.currentLevel = 0
        self.selectedLevel = 0
        self.remainingGuesses = 0
        self.totalPlayTime = 0
        self.completedLevels = []
        self.completionTimes = [:]

        let tempCurrentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        let tempRemainingGuesses = UserDefaults.standard.integer(forKey: "remainingGuesses")
        let tempCoins = UserDefaults.standard.integer(forKey: "coins")
        let tempIsPremium = UserDefaults.standard.bool(forKey: "isPremium")
        let tempTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? Theme.light.rawValue
        let tempCompletedLevels = UserDefaults.standard.array(forKey: "completedLevels") as? [Int] ?? []
        self.selectedTheme = Theme(rawValue: tempTheme) ?? .light
        self.totalPlayTime = UserDefaults.standard.double(forKey: "totalPlayTime")
        self.completedLevels = Set(tempCompletedLevels)

        self.currentLevel = tempCurrentLevel == 0 ? 1 : tempCurrentLevel
        self.selectedLevel = self.currentLevel
        UserDefaults.standard.set(self.currentLevel, forKey: "currentLevel")

        // UserDefaults’tan yalnızca bir kez oku
        self.remainingGuesses = tempRemainingGuesses == 0 ? 3 : tempRemainingGuesses

        self.coins = tempCoins
        self.isPremium = tempIsPremium

        // Tamamlama sürelerini UserDefaults’tan yükle
        if let savedTimes = UserDefaults.standard.dictionary(forKey: "completionTimes") as? [String: Double] {
            self.completionTimes = savedTimes.reduce(into: [Int: Double]()) { result, pair in
                if let level = Int(pair.key) {
                    result[level] = pair.value
                }
            }
        }

        resetCoinsIfNeeded()
        loadLevels()
        setupLevel()

        startSession()
    }

    public var levelCount: Int {
        return levels.count
    }

    public func completedLevelCount() -> Int {
        return completedLevels.count
    }

    private func resetCoinsIfNeeded() {
        let lastResetDate = UserDefaults.standard.object(forKey: "lastCoinResetDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let now = Date()

        if !calendar.isDate(lastResetDate, inSameDayAs: now) {
            coins = 3
            UserDefaults.standard.set(coins, forKey: "coins")
            UserDefaults.standard.set(now, forKey: "lastCoinResetDate")
            print("Jetonlar sıfırlandı: \(coins)")
        }
    }

    private func loadLevels() {
        guard let url = Bundle.main.url(forResource: "levels", withExtension: "json") else {
            print("levels.json dosyası bulunamadı!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            levels = try decoder.decode([Level].self, from: data)
            print("Bölümler yüklendi: \(levels.count) bölüm")
        } catch {
            print("JSON okuma hatası: \(error)")
        }
    }

    func setupLevel() {
        guard let levelData = levels.first(where: { $0.level == selectedLevel }) else {
            print("Bölüm \(selectedLevel) bulunamadı!")
            return
        }

        board = Board(size: levelData.size)
        for row in 0..<levelData.size {
            for col in 0..<levelData.size {
                switch levelData.initialGrid[row][col] {
                case "black":
                    board.grid[row][col] = .black
                case "white":
                    board.grid[row][col] = .white
                default:
                    board.grid[row][col] = .empty
                }
            }
        }

        for signData in levelData.signs {
            let position = Position(from: (signData.from[0], signData.from[1]), to: (signData.to[0], signData.to[1]))
            switch signData.type {
            case "equals":
                board.signs[position] = .equals
            case "cross":
                board.signs[position] = .cross
            case "notEquals":
                board.signs[position] = .notEquals
            case "arrow":
                board.signs[position] = .arrow
            default:
                break
            }
        }

        solution = Array(repeating: Array(repeating: .empty, count: levelData.size), count: levelData.size)
        for row in 0..<levelData.size {
            for col in 0..<levelData.size {
                switch levelData.solution[row][col] {
                case "black":
                    solution[row][col] = .black
                case "white":
                    solution[row][col] = .white
                default:
                    solution[row][col] = .empty
                }
            }
        }

        for row in 0..<levelData.size {
            for col in 0..<levelData.size {
                if levelData.initialGrid[row][col] != "empty" {
                    let initialSymbol: Symbol
                    switch levelData.initialGrid[row][col] {
                    case "black":
                        initialSymbol = .black
                    case "white":
                        initialSymbol = .white
                    default:
                        continue
                    }
                    if solution[row][col] != initialSymbol {
                        print("Hata: Seviye \(selectedLevel) için initialGrid ve solution uyumsuz - (\(row), \(col)) karesi initialGrid'de \(initialSymbol.rawValue), solution'da \(solution[row][col].rawValue)")
                    }
                }
            }
        }

        var solutionBoard = Board(size: levelData.size)
        solutionBoard.grid = solution
        solutionBoard.signs = board.signs
        let (isValid, message) = solutionBoard.isValid()
        if !isValid {
            print("Hata: Seviye \(selectedLevel) için solution dizisi geçersiz: \(message)")
        } else {
            print("Seviye \(selectedLevel) için solution dizisi geçerli.")
        }

        history = []
        levelCompleted = false
        remainingGuesses = 3
        UserDefaults.standard.set(remainingGuesses, forKey: "remainingGuesses")
    }

    func toggleSymbol(at position: (Int, Int)) {
        let (row, col) = position
        let previousSymbol = board.grid[row][col]
        history.append((position, previousSymbol))

        print("Tıklanan pozisyon: (\(row), \(col)), Önceki sembol: \(previousSymbol.rawValue)")

        switch board.grid[row][col] {
        case .empty:
            board.grid[row][col] = .black
            print("Yeni sembol: black")
        case .black:
            board.grid[row][col] = .white
            print("Yeni sembol: white")
        case .white:
            board.grid[row][col] = .empty
            print("Yeni sembol: empty")
        }

        // board’u tamamen yeni bir nesneyle değiştir
        var newBoard = Board(size: board.size)
        newBoard.grid = board.grid
        newBoard.signs = board.signs
        self.board = newBoard
    }

    func undo() {
        guard let lastMove = history.popLast() else { return }
        let (position, previousSymbol) = lastMove
        let (row, col) = position
        board.grid[row][col] = previousSymbol

        // board’u tamamen yeni bir nesneyle değiştir
        var newBoard = Board(size: board.size)
        newBoard.grid = board.grid
        newBoard.signs = board.signs
        self.board = newBoard
    }

    func hint() {
        guard coins > 0 || isPremium else {
            errorMessage = "Jetonunuz bitti! Reklam izleyerek jeton kazanabilirsiniz."
            return
        }

        var emptyPositions: [(Int, Int)] = []
        for row in 0..<board.size {
            for col in 0..<board.size {
                if board.grid[row][col] == .empty {
                    emptyPositions.append((row, col))
                }
            }
        }

        guard let position = emptyPositions.randomElement() else {
            errorMessage = "Boş kare yok!"
            return
        }

        let (row, col) = position
        board.grid[row][col] = solution[row][col]
        print("İpucu ile kare dolduruldu: (\(row), \(col)), yeni sembol: \(board.grid[row][col].rawValue)")
        if !isPremium {
            coins -= 1
            UserDefaults.standard.set(coins, forKey: "coins")
        }
        history.append((position, .empty))

        // board’u tamamen yeni bir nesneyle değiştir
        var newBoard = Board(size: board.size)
        newBoard.grid = board.grid
        newBoard.signs = board.signs
        self.board = newBoard

        // Tüm kareler doldurulduktan sonra board’un durumunu kontrol et
        for row in 0..<board.size {
            for col in 0..<board.size {
                if board.grid[row][col] == .empty {
                    print("Boş kare bulundu: (\(row), \(col))")
                }
            }
        }
    }

    func checkBoard(completionTime: Double? = nil) {
        print("checkBoard çalıştı, levelCompleted: \(levelCompleted)")
        if !isPremium {
            guard coins > 0 else {
                errorMessage = "Jetonunuz bitti! Reklam izleyerek jeton kazanabilirsiniz."
                return
            }
        }

        // Tahtanın solution ile eşleşip eşleşmediğini doğrudan kontrol et
        var isMatchingSolution = true
        for row in 0..<board.size {
            for col in 0..<board.size {
                if board.grid[row][col] != solution[row][col] {
                    isMatchingSolution = false
                    print("Eşleşme hatası: (\(row), \(col)) - board: \(board.grid[row][col].rawValue), solution: \(solution[row][col].rawValue)")
                    break
                }
            }
            if !isMatchingSolution {
                break
            }
        }

        if isMatchingSolution {
            levelCompleted = true
            completedLevels.insert(selectedLevel)
            UserDefaults.standard.set(Array(completedLevels), forKey: "completedLevels")
            if let time = completionTime {
                saveCompletionTime(level: selectedLevel, time: time)
            }
            if selectedLevel == currentLevel {
                currentLevel += 1
                UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
            }
            errorMessage = "" // errorMessage’ı sıfırla
        } else {
            // Önce kalan tahmin hakkını güncelle
            remainingGuesses -= 1
            print("Yanlış! Kalan tahmin hakkı: \(remainingGuesses)")
            
            // Hata mesajını güncelle
            errorMessage = "Başarısız! Kalan tahmin hakkı: \(remainingGuesses)"
            
            // Kalan tahmin hakkı 0’a düştüğünde sıfırlama işlemini yap
            if remainingGuesses == 0 {
                if !isPremium {
                    coins -= 1
                    UserDefaults.standard.set(coins, forKey: "coins")
                    print("Jeton bitti! Kalan jeton: \(coins)")
                }
                remainingGuesses = 3
                errorMessage = "Başarısız! Tahmin hakkınız sıfırlandı. Kalan tahmin hakkı: \(remainingGuesses)"
                print("Tahmin hakkı sıfırlandı: \(remainingGuesses)")
            }
            
            // UserDefaults’a güncellenmiş değeri yaz
            UserDefaults.standard.set(remainingGuesses, forKey: "remainingGuesses")
        }
    }

    // history’nin boş olup olmadığını kontrol eden yardımcı fonksiyon
    func isHistoryEmpty() -> Bool {
        return history.isEmpty
    }

    private func saveCompletionTime(level: Int, time: Double) {
        completionTimes[level] = time
        // UserDefaults’a kaydet
        let timesToSave = completionTimes.reduce(into: [String: Double]()) { result, pair in
            result[String(pair.key)] = pair.value
        }
        UserDefaults.standard.set(timesToSave, forKey: "completionTimes")
        print("Seviye \(level) tamamlama süresi kaydedildi: \(time) saniye")
    }

    func getCompletionTime(forLevel level: Int) -> Double? {
        return completionTimes[level]
    }

    func proceedToNextLevel() {
        selectedLevel = currentLevel
        remainingGuesses = 3
        UserDefaults.standard.set(remainingGuesses, forKey: "remainingGuesses")
        errorMessage = ""
        setupLevel()
    }

    func isLevelCompleted(_ level: Int) -> Bool {
        return completedLevels.contains(level)
    }

    func watchAdForCoin() {
        coins += 1
        UserDefaults.standard.set(coins, forKey: "coins")
        errorMessage = "Reklam izlendi! 1 jeton kazandınız."
    }

    func purchasePremium() {
        isPremium = true
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        errorMessage = "Premium satın alındı! Sınırsız oyun hakkı kazandınız."
    }

    func setTheme(_ theme: Theme) {
        selectedTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }

    func startSession() {
        sessionStartTime = Date()
    }

    func endSession() {
        guard let startTime = sessionStartTime else { return }
        let sessionDuration = Date().timeIntervalSince(startTime)
        totalPlayTime += sessionDuration
        UserDefaults.standard.set(totalPlayTime, forKey: "totalPlayTime")
        sessionStartTime = nil
    }
}
