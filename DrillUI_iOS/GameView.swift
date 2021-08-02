//
//  GameView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct GameView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Spacer()

            // Hold piece column
            VStack {
                HoldPieceView()
            }
            .aspectRatio(0.2, contentMode: .fit)

            // Game field column
            FieldView(field: GameState(garbageCount: 8).field)
                .layoutPriority(1)

            // Preview piece column
            VStack {
                NextPiecesView()
            }
            .aspectRatio(0.2, contentMode: .fit)

            Spacer()
        }
        // An empirically measured approximation is 83/90 or 0.9222...,
        // make it a bit wider than that
        .aspectRatio(0.93, contentMode: .fit)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
