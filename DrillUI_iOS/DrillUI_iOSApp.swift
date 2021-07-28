//
//  DrillAI_iOSApp.swift
//  DrillAI-iOS
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


@main
struct DrillAI_iOSApp: App {

    @State private var state: GameState
    @State private var bot: DrillBot<BCTSEvaluator>
    @State private var legalMoves: [Piece]
    @State private var outputs: [ConsoleOutput]
    @State private var highlightedMove: Piece? = nil

    let evaluator: BCTSEvaluator

    init() {

        let state = GameState(garbageCount: 8)
        self.state = state
        self.evaluator = BCTSEvaluator()
        self.bot = DrillBot(initialState: state, evaluator: evaluator)
        self.legalMoves = state.getLegalActions()
        self.outputs = [ConsoleOutput("New Game!"), ConsoleOutput(state.field.debugDescription)]
    }

    var body: some Scene {
        WindowGroup {
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    ControlView(controlAction: handleControlAction,
                                legalMoves: $legalMoves,
                                highlightedMove: $highlightedMove)
                    Spacer()
                }
                ConsoleView(outputs: $outputs)
                    .frame(width: 300)
                    .foregroundColor(.init(white: 0.9))
            }
            .frame(minWidth: 400, idealWidth: 800, maxWidth: .infinity,
                   minHeight: 300, idealHeight: 600, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}


private extension DrillAI_iOSApp {
    func handleControlAction(_ action: ControlView.ActionType) {
        switch action {
        case .newGame:
            state = GameState(garbageCount: 8)
            bot = DrillBot(initialState: state, evaluator: evaluator)
            legalMoves = state.getLegalActions()
            outputs = [ConsoleOutput("New Game!")]
            outputs.append(ConsoleOutput(state.field.debugDescription))

        case .botStep:
            highlightedMove = nil
            bot.makeMoveWithCallback { action in
//                let message = action?.debugDescription ?? "No move"
//                outputs.append(ConsoleOutput(message))
                highlightedMove = action
            }

        case .step(let piece):
            state = state.getNextState(for: piece)
            bot = DrillBot(initialState: state, evaluator: evaluator)
            legalMoves = state.getLegalActions()
            outputs.append(ConsoleOutput(state.field.debugDescription))
        }
    }
}
