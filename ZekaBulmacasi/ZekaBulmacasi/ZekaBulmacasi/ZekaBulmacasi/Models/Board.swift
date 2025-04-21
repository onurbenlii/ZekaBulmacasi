// Board.swift
import Foundation

enum Symbol: String, Codable {
    case empty
    case black // 🌙
    case white // 🟡
}

enum Sign: String, Codable {
    case equals // =
    case cross // X
    case notEquals
    case arrow
}

struct Position: Hashable, Codable, Equatable {
    let fromRow: Int
    let fromCol: Int
    let toRow: Int
    let toCol: Int

    // Codable için gerekli init ve coding keys
    enum CodingKeys: String, CodingKey {
        case fromRow = "from_row"
        case fromCol = "from_col"
        case toRow = "to_row"
        case toCol = "to_col"
    }

    init(from: (Int, Int), to: (Int, Int)) {
        self.fromRow = from.0
        self.fromCol = from.1
        self.toRow = to.0
        self.toCol = to.1
    }

    // Equatable için == fonksiyonu
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.fromRow == rhs.fromRow &&
               lhs.fromCol == rhs.fromCol &&
               lhs.toRow == rhs.toRow &&
               lhs.toCol == rhs.toCol
    }

    // Hashable için hash fonksiyonu
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromRow)
        hasher.combine(fromCol)
        hasher.combine(toRow)
        hasher.combine(toCol)
    }

    // Yardımcı fonksiyon: Eski kodlarla uyumluluk için
    var from: (Int, Int) {
        return (fromRow, fromCol)
    }

    var to: (Int, Int) {
        return (toRow, toCol)
    }
}

struct Board {
    var grid: [[Symbol]]
    var signs: [Position: Sign]
    let size: Int

    init(size: Int) {
        self.size = size
        self.grid = Array(repeating: Array(repeating: .empty, count: size), count: size)
        self.signs = [:]
    }

    func isValid() -> (Bool, String) {
        // Kural 1: Tüm hücreler dolu olmalı (empty hücre kalmamalı)
        for row in 0..<size {
            for col in 0..<size {
                if grid[row][col] == .empty {
                    return (false, "Hata: (\(row), \(col)) karesi boş!")
                }
            }
        }

        // Kural 2: Yatay ve dikey olarak aynı türden en fazla 2 hücre yan yana olabilir
        // Yatay kontrol
        for row in 0..<size {
            for col in 0..<(size - 2) {
                if grid[row][col] != .empty && grid[row][col] == grid[row][col + 1] && grid[row][col] == grid[row][col + 2] {
                    return (false, "Hata: (\(row), \(col)) satırında 3 aynı sembol yan yana!")
                }
            }
        }

        // Dikey kontrol
        for col in 0..<size {
            for row in 0..<(size - 2) {
                if grid[row][col] != .empty && grid[row][col] == grid[row + 1][col] && grid[row][col] == grid[row + 2][col] {
                    return (false, "Hata: (\(row), \(col)) sütununda 3 aynı sembol yan yana!")
                }
            }
        }

        // Kural 3: Her satır ve sütun eşit sayıda black ve white içermeli (6x6 için 3 black, 3 white)
        for row in 0..<size {
            let blackCount = grid[row].filter { $0 == .black }.count
            let whiteCount = grid[row].filter { $0 == .white }.count
            if blackCount != 3 || whiteCount != 3 {
                return (false, "Hata: \(row). satırda \(blackCount) black ve \(whiteCount) white var, eşit olmalı!")
            }
        }

        for col in 0..<size {
            let blackCount = (0..<size).filter { grid[$0][col] == .black }.count
            let whiteCount = (0..<size).filter { grid[$0][col] == .white }.count
            if blackCount != 3 || whiteCount != 3 {
                return (false, "Hata: \(col). sütunda \(blackCount) black ve \(whiteCount) white var, eşit olmalı!")
            }
        }

        // Kural 4: = işaretiyle ayrılan hücreler aynı türde olmalı
        // Kural 5: X işaretiyle ayrılan hücreler zıt türde olmalı
        for (position, sign) in signs {
            let (row1, col1) = position.from
            let (row2, col2) = position.to

            let symbol1 = grid[row1][col1]
            let symbol2 = grid[row2][col2]

            if symbol1 == .empty || symbol2 == .empty {
                return (false, "Hata: İşaretli hücreler boş! (\(row1), \(col1)) ve (\(row2), \(col2))")
            }

            switch sign {
            case .equals:
                if symbol1 != symbol2 {
                    return (false, "Hata: (\(row1), \(col1)) ve (\(row2), \(col2)) aynı türde olmalı!")
                }
            case .cross:
                if symbol1 == symbol2 {
                    return (false, "Hata: (\(row1), \(col1)) ve (\(row2), \(col2)) zıt türde olmalı!")
                }
            case .notEquals:
                if symbol1 == symbol2 {
                    return (false, "Hata: (\(row1), \(col1)) ve (\(row2), \(col2)) farklı türde olmalı!")
                }
            case .arrow:
                // Arrow işareti şu an kullanılmıyor, bu yüzden bu kuralı atlıyoruz
                break
            }
        }

        return (true, "Tahta geçerli!")
    }
}
