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
        case newGame(Int)
        case botPlay
        case step(Piece)
    }

    private let controlAction: (ActionType) -> Void
    @Binding private var legalMoves: [ActionVisits]
    @Binding private var highlightedMove: Piece?

    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 20)
            HStack {
                Spacer()
                Button("New Game (10)") { controlAction(.newGame(10)) }
                .padding()
                Button("New Game (18)") { controlAction(.newGame(18)) }
                .padding()
                Button("New Game (100)") { controlAction(.newGame(100)) }
                .padding()
                Button("Bot Play") { controlAction(.botPlay) }
                .padding()
                Spacer()
            }
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(legalMoves, id: \.action.code) { actionVisits in
                            Button {
                                controlAction(.step(actionVisits.action))
                            } label: {
                                HStack {
                                    Text("\(actionVisits.visits)")
                                    Text(actionVisits.action.debugDescription)
                                        .frame(maxWidth: .infinity)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.gray, lineWidth: 1))
                                        .background(actionVisits.action == highlightedMove ? Color.yellow : Color.clear)
                                        .cornerRadius(16)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(2)
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
                            scrollView.scrollTo(firstMove.action.code)
                        }
                    }
                }
            }
        }
    }

    init(controlAction: ((ActionType) -> Void)? = nil,
         legalMoves: Binding<[ActionVisits]> = .constant([]),
         highlightedMove: Binding<Piece?> = .constant(nil)) {
        self.controlAction = controlAction ?? { _ in }
        self._legalMoves = legalMoves
        self._highlightedMove = highlightedMove
    }
}


extension MCTSTree.ActionVisits: Equatable where State == GameState {
    public static func == (lhs: MCTSTree.ActionVisits, rhs: MCTSTree.ActionVisits) -> Bool {
        lhs.action == rhs.action && lhs.visits == rhs.visits
    }
}


struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}
