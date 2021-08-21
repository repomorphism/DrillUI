//
//  HoldPieceView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct HoldPieceView: View {
    let type: Tetromino?
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.clear)
                .aspectRatio(4 / 20, contentMode: .fit)
                .padding(2)
                .layoutPriority(1)
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .border(Color("Game Blocks Border"), width: 1.0)
                    .padding(1)
                if let type = type {
                    PieceView(piece: Piece(type: type, x: 0, y: 0, orientation: .up))
                        .aspectRatio(4 / 2, contentMode: .fit)
                        .padding(2)
                }
            }
        }
    }
}

struct HoldPieceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HoldPieceView(type: .T)
                .background(Color(white: 0.05))
            Spacer()
        }
            .frame(width: 300, height: 1000)
            .background(Color(white: 0.25))
    }
}
