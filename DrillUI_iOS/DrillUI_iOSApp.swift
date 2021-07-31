//
//  DrillAI_iOSApp.swift
//  DrillAI-iOS
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


typealias ActionVisits = MCTSTree<GameState>.ActionVisits

let initialGameLength = 18

@main
struct DrillAI_iOSApp: App {

    @State private var state: GameState
    @State private var bot: DrillBot<BCTSEvaluator>
    @State private var legalMoves: [ActionVisits]
    @State private var outputs: [ConsoleOutput]
    @State private var highlightedMove: Piece? = nil

    let evaluator: BCTSEvaluator

    init() {

        let state = GameState(garbageCount: initialGameLength)
        self.state = state
        self.evaluator = BCTSEvaluator()
        self.bot = DrillBot(initialState: state, evaluator: evaluator)
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
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
        case .newGame(let count):
            state = GameState(garbageCount: count)
            bot = DrillBot(initialState: state, evaluator: evaluator)
            legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }

            outputs = [ConsoleOutput("New Game!")]
            outputs.append(ConsoleOutput(state.field.debugDescription))

        case .botPlay:
            highlightedMove = nil
            Task {
                let sortedActions = await bot.thinkTillEnough()
                legalMoves = sortedActions
                highlightedMove = legalMoves.first?.action

                // Saves me a click, but this is dangerous (race condition)
                if let bestMove = legalMoves.first {
                    await Task.sleep(750_000_000)
                    handleControlAction(.step(bestMove.action))
                    handleControlAction(.botPlay)
                }
            }

        case .step(let piece):
            Task {
                state = await bot.advance(with: piece)
                let sortedActions = await bot.getSortedActions()
                legalMoves = sortedActions
//                highlightedMove = legalMoves.first?.action
//                let message = "\(state.field.debugDescription)\nStep:\(state.dropCount)"
                let message = """
                    \(Date.now)
                    \(state.field.debugDescription)
                    Step: \(state.dropCount), cleared: \(state.garbageCleared)
                    """
                outputs.append(ConsoleOutput(message))
            }
            
//            state = state.getNextState(for: piece)
//            bot = DrillBot(initialState: state, evaluator: evaluator)
//            legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
//
//            outputs.append(ConsoleOutput(state.field.debugDescription))
        }
    }
}
