//
//  FieldView.swift
//
//
//  Created by Paul on 8/2/21.
//

import SwiftUI
import DrillUILib
import DrillAI


struct FieldView: View {

    let displayField: DisplayField
    let playPiece: Piece?
    
    var body: some View {
        ZStack {
            GridLinesView()
                .aspectRatio(0.5, contentMode: .fit)    // 10:20 aspect
                .padding(2)
                .layoutPriority(1)  // This just needs to be on the one with aspect ratio
            FieldRowsView(field: displayField)
                .padding(2)
            Rectangle()
                .fill(.clear)
                .border(Color(white: 0.75), width: 2.0)
            if let playPiece = playPiece {
                // Live piece
                PlayPieceView(piece: playPiece)
                    .padding(2)
                // Ghost piece
//                PlayPieceView(piece: displayField.field.makeGhost(of: playPiece), isGhost: true)
//                    .padding(2)
            }
        }
        .clipped()  // Hide >20 rows when animating new garbage
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        let field = GameState(garbageCount: 8).field
        FieldView(displayField: DisplayField(from: field), playPiece: nil)
            .background(Color(white: 0.05))
            .previewLayout(.sizeThatFits)
    }
}
