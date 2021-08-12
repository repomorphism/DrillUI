//
//  PieceView.swift
//  PieceView
//
//  Created by Paul on 8/5/21.
//

import SwiftUI
import DrillAI


struct PieceView: View {

    let piece: Piece
    let isGhost: Bool

    init(piece: Piece, isGhost: Bool = false) {
        self.piece = piece
        self.isGhost = isGhost
    }

    var body: some View {
        let cellPositions = piece.cellPositions
        let minX = cellPositions.map(\.x).min()!
        let maxX = cellPositions.map(\.x).max()!
        let minY = cellPositions.map(\.y).min()!
        let maxY = cellPositions.map(\.y).max()!
        let yValues = Array((minY...maxY).reversed())
        VStack(spacing: 0) {
            ForEach(yValues, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(minX ..< maxX + 1, id: \.self) { x in
                        if cellPositions.contains { $0.x == x && $0.y == y } {
                            MinoCellView(type: isGhost ? .ghost(piece.type) : .live(piece.type))
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
        .aspectRatio(CGFloat(maxX - minX + 1) / CGFloat(maxY - minY + 1),
                     contentMode: .fit)
    }
}

struct PieceView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(piece: Piece(type: .L, x: 4, y: 15, orientation: .up))
    }
}
