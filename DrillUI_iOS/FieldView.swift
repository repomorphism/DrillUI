//
//  FieldView.swift
//
//
//  Created by Paul on 8/2/21.
//

import SwiftUI
import DrillAI


struct FieldView: View {

    let displayField: DisplayField
    let playPiece: Piece?
    
    var body: some View {
        ZStack {
            GridLinesView()
                .padding(2)
            FieldCellsView(field: displayField)
                .padding(2)
            Rectangle()
                .strokeBorder(Color(white: 0.75), lineWidth: 2.0)
            if let playPiece = playPiece {
                PlayPieceView(piece: playPiece)
            }
        }
        .aspectRatio(0.5, contentMode: .fit)
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        let field = GameState(garbageCount: 8).field
        FieldView(displayField: DisplayField(from: field), playPiece: nil)
            .background(Color(white: 0.05))
//            .previewInterfaceOrientation(.landscapeRight)
            .previewLayout(.sizeThatFits)
    }
}
