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
    var body: some View {
        VStack {
            Spacer()
            Text(piece.debugDescription)
                .font(.system(.largeTitle, design: .monospaced))
                .foregroundColor(.blue)
            Spacer()
            Spacer()
        }
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
