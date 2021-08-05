//
//  GameplayController.swift
//
//
//  Created by Paul on 8/4/21.
//

import Foundation
import Combine
import DrillAI


final class GameplayController: ObservableObject {

    @Published var state: GameState
    @Published var legalMoves: [ActionVisits] = []

    // Don't need to @Publish this because it's tied with state's change
    var displayField: DisplayField

    var field: Field {
        state.field
    }

    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?

    init() {
        let state = GameState(garbageCount: 8)
        let evaluator = BCTSEvaluator()
        self.state = state
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)
        self.displayField = DisplayField(from: state.field)
    }

    func startNewGame(garbageCount count: Int) {
        let newState = GameState(garbageCount: count)
        let evaluator = BCTSEvaluator()
        state = newState
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        displayField = DisplayField(from: state.field)
        legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
    }

    func startThinking() {
        bot.startThinking()
        startTimer()
    }

    func stopThinking() {
        bot.stopThinking()
        stopTimer()
    }

    func play(_ piece: Piece) {
        let isThinking = bot.isThinking
        stopThinking()
        Task { [weak self] in
            let newState = await bot.advance(with: piece)
            let legalMoves = await self?.bot.getActions()
            await self?.updateValues(state: newState,
                                     legalMoves: legalMoves,
                                     piece: piece)
            if isThinking {
                self?.startThinking()
            }
        }
    }
}

private extension GameplayController {
    func updateValues(state: GameState? = nil,
                      legalMoves: [ActionVisits]? = nil,
                      piece: Piece? = nil) async {
        let newDisplayField: DisplayField?
        if let state = state, let piece = piece {
            newDisplayField = displayField.nextDisplayField(placing: piece, matching: state.field)
        } else {
            newDisplayField = nil
        }

        await MainActor.run { [weak self] in
            if let state = state {
                self?.state = state
            }
            if let legalMoves = legalMoves {
                self?.legalMoves = legalMoves
            }
            if let displayField = newDisplayField {
                self?.displayField = displayField
            }
        }
    }

    func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    let legalMoves = await self?.bot.getActions()
                    await self?.updateValues(legalMoves: legalMoves)
                }
            }
    }

    func stopTimer() {
        timerSubscription = nil
    }
}

