//
//  GameView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct GameView: View {

    let state: GameState
    let displayField: DisplayField

    var body: some View {
        let piece = Piece(type: state.playPiece, x: 4, y: 18, orientation: .up)
        HStack(alignment: .top, spacing: 0) {
            Spacer(minLength: 0)
            HoldPieceView(type: state.hold)
            Spacer(minLength: 0)
            FieldView(displayField: displayField, playPiece: piece)
            Spacer(minLength: 0)
            NextPiecesView(nextPieceTypes: state.nextPieceTypes)
            Spacer(minLength: 0)
        }
        // A 0.92 ratio is just about enough, extra widths go into spacers.
        // If not wide enough, one of them will shrink to incorrect size.
        .aspectRatio(0.925, contentMode: .fit)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let state = GameState(garbageCount: 4)
        GameView(state: state, displayField: DisplayField(from: state.field))
            .background(Color(white: 0.05))
//            .previewInterfaceOrientation(.landscapeRight)
            .previewLayout(.sizeThatFits)
    }
}
