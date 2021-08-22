//
//  NextPiecesView.swift
//  NextPiecesView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct NextPiecesView: View {

    let nextPieceTypes: [Tetromino]

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.clear)
                .aspectRatio(4 / 20, contentMode: .fit)
                .padding(2)
                .layoutPriority(1)
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(4 / 15, contentMode: .fit)
                    .border(Color("Game Blocks Border"), width: 1.0)
                    .padding(1)
                VStack(spacing: 0) {
                    ForEach(Array(nextPieceTypes.enumerated()), id: \.0) { (index, type) in
                        ZStack {
                            Rectangle()
                                .fill(.clear)
                                .aspectRatio(4 / 3, contentMode: .fit)
                            PieceView(piece: Piece(type: type, x: 0, y: 0, orientation: .up))
                                .aspectRatio(4 / 2, contentMode: .fit)
                        }
                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                    }
                }
            }
        }
    }
}

struct PreviewPiecesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NextPiecesView(nextPieceTypes: [])
                .background(Color(white: 0.05))
            Spacer()
        }
            .frame(width: 300, height: 1000)
            .background(Color(white: 0.25))
//            .previewLayout(.sizeThatFits)
    }
}
