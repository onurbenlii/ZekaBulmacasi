// BoardView.swift
import SwiftUI

struct BoardView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        // Hücre boyutunu dinamik olarak ayarla (6x6 tahta için küçült)
        let cellSize: CGFloat = game.board.size == 6 ? 50 : 60
        let spacing: CGFloat = game.board.size == 6 ? 6 : 8

        VStack(spacing: spacing) {
            ForEach(0..<game.board.size, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<game.board.size, id: \.self) { col in
                        CellView(game: game, row: row, col: col, cellSize: cellSize)
                    }
                }
            }
        }
        .overlay(
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(game.board.signs.keys), id: \.self) { position in
                        let (row1, col1) = position.from
                        let (row2, col2) = position.to
                        let (midX, midY) = calculateSignPosition(row1: row1, col1: col1, row2: row2, col2: col2, cellSize: cellSize, spacing: spacing)

                        // İşareti sembol olarak göster
                        Text(signSymbol(for: game.board.signs[position]!))
                            .font(.system(size: game.board.size == 6 ? 14 : 16, weight: .bold))
                            .foregroundColor(game.board.signs[position] == .cross || game.board.signs[position] == .notEquals ? Color(appHex: "#FF3B30") : Color(appHex: "#4682B4"))
                            .position(x: midX, y: midY)
                    }
                }
            }
        )
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(game.selectedTheme.boardBackgroundColor)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }

    // İşareti sembol olarak döndüren yardımcı fonksiyon
    private func signSymbol(for sign: Sign) -> String {
        switch sign {
        case .equals:
            return "="
        case .cross:
            return "X"
        case .notEquals:
            return "≠"
        case .arrow:
            return "→"
        }
    }

    // İşaretlerin konumunu hesaplayan yardımcı fonksiyon
    private func calculateSignPosition(row1: Int, col1: Int, row2: Int, col2: Int, cellSize: CGFloat, spacing: CGFloat) -> (CGFloat, CGFloat) {
        let offsetX: CGFloat = CGFloat(col1) * (cellSize + spacing) + cellSize / 2
        let offsetY: CGFloat = CGFloat(row1) * (cellSize + spacing) + cellSize / 2
        let offsetX2: CGFloat = CGFloat(col2) * (cellSize + spacing) + cellSize / 2
        let offsetY2: CGFloat = CGFloat(row2) * (cellSize + spacing) + cellSize / 2

        let midX = (offsetX + offsetX2) / 2
        let midY = (offsetY + offsetY2) / 2
        return (midX, midY)
    }
}

// Hücreyi ayrı bir View olarak tanımlıyoruz
struct CellView: View {
    @ObservedObject var game: GameModel
    let row: Int
    let col: Int
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(game.selectedTheme.cellColor)
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.selectedTheme.cellBorderColor, lineWidth: 2)
                )

            if game.board.grid[row][col] != .empty {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                game.board.grid[row][col] == .black ? Color.black.opacity(0.9) : Color.white,
                                game.board.grid[row][col] == .black ? Color.black.opacity(0.7) : Color.white.opacity(0.8)
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: cellSize / 2
                        )
                    )
                    .frame(width: cellSize - 10, height: cellSize - 10)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                game.toggleSymbol(at: (row, col))
            }
        }
    }
}

#Preview {
    BoardView(game: GameModel())
}
