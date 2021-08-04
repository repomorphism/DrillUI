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
        case botStartThinking
        case botStopThinking
        case play(Piece)
    }

    let controlAction: (ActionType) -> Void
    let legalMoves: [ActionVisits]
    let highlightedMove: Piece?

    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 20)
            VStack(spacing: 4) {
                Button("New Game (10)") { controlAction(.newGame(10)) }
                Button("New Game (18)") { controlAction(.newGame(18)) }
                Button("Bot Play") { controlAction(.botStartThinking) }
                Button("Bot Stop") { controlAction(.botStopThinking) }
            }
            .foregroundColor(.blue)
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack {
                        ForEach(legalMoves, id: \.action.code) { actionVisits in
                            Button {
                                controlAction(.play(actionVisits.action))
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
}


extension MCTSTree.ActionVisits: Equatable where State == GameState {
    public static func == (lhs: MCTSTree.ActionVisits, rhs: MCTSTree.ActionVisits) -> Bool {
        lhs.action == rhs.action && lhs.visits == rhs.visits
    }
}


struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(controlAction: { _ in }, legalMoves: [], highlightedMove: nil)
    }
}
