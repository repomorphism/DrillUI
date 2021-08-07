//
//  PlayPieceView.swift
//  PlayPieceView
//
//  Created by Paul on 8/4/21.
//

import SwiftUI
import DrillAI


struct PlayPieceView: View {

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

        Rectangle()
            .fill(.clear)
            .overlay(GeometryReader { proxy in
                let cellWidth = proxy.size.width / 10
                let cellHeight = proxy.size.height / 20
                let pieceWidth = CGFloat(maxX - minX + 1) * cellWidth
                let pieceHeight = CGFloat(maxY - minY + 1) * cellHeight
                let pieceX = CGFloat(minX) * cellWidth + pieceWidth / 2
                let pieceY = CGFloat(19 - maxY) * cellHeight + pieceHeight / 2
                PieceView(piece: piece, isGhost: isGhost)
                    .frame(width: pieceWidth, height: pieceHeight)
                    .position(x: pieceX, y: pieceY)
            })
    }
}

struct PlayPieceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PlayPieceView(piece: Piece(type: .L, x: 4, y: 15, orientation: .up))
                .background(Color(white: 0.05))
            Spacer()
        }
            .frame(width: 300, height: 1000)
            .background(Color(white: 0.25))

    }
}
