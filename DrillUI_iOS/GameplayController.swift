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

    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now

    init() {
        let state = GameState(garbageCount: 8)
        let evaluator = BCTSEvaluator()
        self.state = state
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)
        self.displayField = DisplayField(from: state.field)
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        defer {
            self.bot.autoStopAction = { [weak self] in self?.handleBotAutoStop() }
        }
    }
}

extension GameplayController {
    var field: Field {
        state.field
    }

    func startNewGame(garbageCount count: Int) {
        let newState = GameState(garbageCount: count)
        let evaluator = BCTSEvaluator()
        state = newState
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        bot.autoStopAction = { [weak self] in self?.handleBotAutoStop() }
        displayField = DisplayField(from: state.field)
        legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
    }

    func startThinking() {
        bot.startThinking()
        startTimer()
        thinkingStartTime = .now
    }

    func stopThinking() {
        bot.stopThinking()
        stopTimer()
    }

    func play(_ piece: Piece, resumeThinkingAfterPlay: Bool? = nil) {
        let resumeThinkingAfterPlay = resumeThinkingAfterPlay ?? bot.isThinking
        stopThinking()

        Task { [weak self, displayField] in
            let newState = await bot.advance(with: piece)
            let newDisplayField = displayField.nextDisplayField(placing: piece, matching: newState.field)

            await self?.update(state: newState, displayField: newDisplayField)
            await self?.updateLegalMoves()
            let legalMoveCount = self?.legalMoves.count ?? 0

            if resumeThinkingAfterPlay, legalMoveCount > 0 {
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

    func shouldAutoplay() -> Bool {
        guard legalMoves.count >= 2 else { return false }
        let topVisits = legalMoves[0].visits

        // Condition 1: Thought for over 5 seconds
        if thinkingStartTime.timeIntervalSinceNow < -5 {
            return true
        }

        // Condition 2: 20k total including some "decisiveness" bonus
        let totalN = legalMoves.map(\.visits).reduce(0, +)
        let ratio = Double(topVisits) / Double(totalN + 1)
        let bonus = Int(max(0, ratio - 0.5) * Double(topVisits))

        if totalN + bonus > 20_000 {
            return true
        }

        return false
    }

    func performAutoplay() {
        if shouldAutoplay() {
            stopThinking()
            let topAction = legalMoves[0].action
            Task {
                await Task.sleep(500_000_000)
                play(topAction, resumeThinkingAfterPlay: true)
            }
        }
    }

    func handleBotAutoStop() {
        stopTimer()
        Task {
            await updateLegalMoves()
            await Task.sleep(500_000_000)
            if let topAction = legalMoves.first?.action {
                play(topAction, resumeThinkingAfterPlay: true)
            }
        }
    }

    func startTimer() {
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    await self?.updateLegalMoves()
                    self?.performAutoplay()
                }
            }
    }

    func stopTimer() {
        timerSubscription = nil
    }
}

