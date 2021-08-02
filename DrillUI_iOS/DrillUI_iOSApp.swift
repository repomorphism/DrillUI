//
//  DrillAI_iOSApp.swift
//  DrillAI-iOS
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


typealias ActionVisits = MCTSTree<GameState>.ActionVisits

private let initialGameLength = 10

@main
struct DrillAI_iOSApp: App {

    @State private var legalMoves: [ActionVisits]
    @State private var outputs: [ConsoleOutput]
    @State private var highlightedMove: Piece? = nil
    @State private var gbot: GeneratorBot<BCTSEvaluator>

    private let timer = Timer.publish(every: 1.0, on: .main, in: .default).autoconnect()

    init() {

        let state = GameState(garbageCount: initialGameLength)
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        self.outputs = [ConsoleOutput("New Game!"), ConsoleOutput(state.field.debugDescription)]

        let evaluator = BCTSEvaluator()
        self.gbot = GeneratorBot(initialState: state, evaluator: evaluator)
    }

    var body: some Scene {
        WindowGroup {
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    FieldView(field: GameState(garbageCount: 8).field)
                        .frame(maxHeight: .infinity)
//                    ControlView(controlAction: handleControlAction,
//                                legalMoves: $legalMoves,
//                                highlightedMove: $highlightedMove)
                    Spacer()
                }
                .background(Color(white: 0.05))
                ConsoleView(outputs: $outputs)
                    .frame(width: 300)
                    .foregroundColor(.init(white: 0.9))
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                Task {
                    legalMoves = await gbot.getActions()
                }
            }
        }
    }
}


private extension DrillAI_iOSApp {
    func handleControlAction(_ action: ControlView.ActionType) {
        switch action {
        case .newGame(let count):
            let state = GameState(garbageCount: count)
            let evaluator = BCTSEvaluator()
            gbot = GeneratorBot(initialState: state, evaluator: evaluator)

            legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
            outputs = [ConsoleOutput("New Game!"), ConsoleOutput(state.field.debugDescription)]

        case .botPlay:
            gbot.startThinking()

        case .step(let piece):
            gbot.stopThinking()
            Task {
                let state = await gbot.advance(with: piece)
                legalMoves = await gbot.getActions()
                gbot.startThinking()
                let message = """
                    \(Date.now)
                    \(state.field.debugDescription)
                    Step: \(state.dropCount), cleared: \(state.garbageCleared)
                    """
                outputs.append(ConsoleOutput(message))
            }
        case .gbotStop:
            gbot.stopThinking()
        }
    }
}
