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

    @State private var state: GameState = GameState(garbageCount: 8)
    @State private var legalMoves: [Piece] = []
    @State private var outputs: [ConsoleOutput] = []
//    let tree: MCTSTree = MCTSTree(initialState: GameState(garbageCount: 8))

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
        case .step(let piece):
            state = state.getNextState(for: piece)
            legalMoves = state.getLegalActions()
            outputs.append(ConsoleOutput(state.field.debugDescription))
        }
    }
}
