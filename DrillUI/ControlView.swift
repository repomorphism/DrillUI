//
//  ControlView.swift
//  ControlView
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


struct ControlView: View {
    enum ActionType {
        case newGame
        case step(Piece)
    }

    let controlAction: (ActionType) -> Void
    let legalMoves: [Piece]

    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 20)
            HStack {
                Spacer()
                Button("New Game") { controlAction(.newGame) }
                .padding()
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(legalMoves, id: \.code) { move in
                        Button {
                            controlAction(.step(move))
                        } label: {
                            Text(move.debugDescription)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
                .font(.system(.body, design: .monospaced))
            }
        }
    }

    init(_ controlAction: ((ActionType) -> Void)? = nil, _ legalMoves: [Piece] = []) {
        self.controlAction = controlAction ?? { _ in }
        self.legalMoves = legalMoves
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}
