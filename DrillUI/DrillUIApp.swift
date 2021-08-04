//
//  DrillUIApp.swift
//  DrillUI
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


@main
struct DrillUIApp: App {

    @State private var state: GameState
//    @State private var bot: DrillBot<BCTSEvaluator>
    @State private var legalMoves: [Piece]
    @State private var outputs: [ConsoleOutput]

    init() {
        let state = GameState(garbageCount: 8)
        self.state = state
//        let evaluator = BCTSEvaluator()
//        self.bot = DrillBot(initialState: state, evaluator: evaluator)
        self.legalMoves = state.getLegalActions()
        self.outputs = [ConsoleOutput("New Game!"), ConsoleOutput(state.field.debugDescription)]
    }

    var body: some Scene {
        WindowGroup {
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    ControlView(handleControlAction, legalMoves)
                    Spacer()
                }
                ConsoleView(outputs: $outputs)
                    .frame(width: 240)
                WindowAccessor().frame(width: 0, height: 0)
            }
            .frame(minWidth: 400, idealWidth: 800, maxWidth: .infinity,
                   minHeight: 300, idealHeight: 600, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

private extension DrillUIApp {
    func handleControlAction(_ action: ControlView.ActionType) {
        switch action {
        case .newGame:
            state = GameState(garbageCount: 8)
            legalMoves = state.getLegalActions()
            outputs = [ConsoleOutput("New Game!")]
            outputs.append(ConsoleOutput(state.field.debugDescription))

        case .botStep:
            break
//            bot.makeMoveWithCallback { action in
//                let message = action?.debugDescription ?? "No move"
//                outputs.append(ConsoleOutput(message))
//            }

        case .play(let piece):
            state = state.getNextState(for: piece)
            legalMoves = state.getLegalActions()
            outputs.append(ConsoleOutput(state.field.debugDescription))
        }
    }
}
