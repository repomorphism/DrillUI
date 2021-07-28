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
        case botStep
        case step(Piece)
    }

    private let controlAction: (ActionType) -> Void
    @Binding private var legalMoves: [Piece]
    @Binding private var highlightedMove: Piece?

    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 20)
            HStack {
                Spacer()
                Button("New Game") { controlAction(.newGame) }
                .padding()
                Button("Bot Think") { controlAction(.botStep) }
                .padding()
                Spacer()
            }
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(legalMoves, id: \.code) { move in
                            Button {
                                controlAction(.step(move))
                            } label: {
                                Text(move.debugDescription)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(move == highlightedMove ? Color.yellow : Color.clear)
                            .cornerRadius(8.0)
                            .border(Color.gray, width: 1)
//                            .padding()
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                }
                .onChange(of: highlightedMove) { move in
                    if let move = move {
                        withAnimation {
                            scrollView.scrollTo(move.code)
                        }
                    }
                }
                .onChange(of: legalMoves) { _ in
                    if let firstMove = legalMoves.first {
                        withAnimation {
                            scrollView.scrollTo(firstMove.code)
                        }
                    }
                }
            }
        }
    }

    init(controlAction: ((ActionType) -> Void)? = nil,
         legalMoves: Binding<[Piece]> = .constant([]),
         highlightedMove: Binding<Piece?> = .constant(nil)) {
        self.controlAction = controlAction ?? { _ in }
        self._legalMoves = legalMoves
        self._highlightedMove = highlightedMove
    }
}


struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}
