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

    var displayField: DisplayField  // Update this whenever state changes

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
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
    }
}

extension GameplayController {
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
        let shouldContinueThinking = bot.isThinking
        stopThinking()

        Task { [weak self, displayField] in
            let newState = await bot.advance(with: piece)
            let newDisplayField = displayField.nextDisplayField(placing: piece, matching: newState.field)

            await self?.update(state: newState, displayField: newDisplayField)
            await self?.updateLegalMoves()

            if shouldContinueThinking {
                self?.startThinking()
            }
        }
    }
}

private extension GameplayController {
    func updateLegalMoves() async {
        let legalMoves = await self.bot.getActions()
        await MainActor.run {
            self.legalMoves = legalMoves
        }
    }

    func update(state: GameState, displayField: DisplayField) async {
        await MainActor.run {
            self.state = state
            self.displayField = displayField
        }
    }

    func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    await self?.updateLegalMoves()
                }
            }
    }

    func stopTimer() {
        timerSubscription = nil
    }
}

