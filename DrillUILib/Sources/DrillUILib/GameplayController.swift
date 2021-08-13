//
//  GameplayController.swift
//
//
//  Created by Paul on 8/4/21.
//

import Foundation
import Combine
import DrillAI


public typealias ActionVisits = MCTSTree<GameState>.ActionVisits


public final class GameplayController: ObservableObject {

    @Published public var legalMoves: [ActionVisits] = []

    public let viewModel: ViewModel

    private var state: GameState
    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now

    public init() {
        let state = GameState(garbageCount: 8)
        let evaluator = BCTSEvaluator()
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        self.viewModel = ViewModel(state: state)
        self.state = state
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)
        self.bot.autoStopAction = { [weak self] in self?.handleBotAutoStop() }
    }
}


public extension GameplayController {
    func startNewGame(garbageCount count: Int) {
        let newState = GameState(garbageCount: count)
        let evaluator = BCTSEvaluator()
        state = newState
        legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        viewModel.reset(to: state)
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        bot.autoStopAction = { [weak self] in self?.handleBotAutoStop() }
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

        Task {
            let newState = await bot.advance(with: piece)
            await updateLegalMoves()
            if resumeThinkingAfterPlay, legalMoves.count > 0 {
                startThinking()
            }
            await viewModel.update(newState: newState, placed: piece)
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

        if totalN + bonus > 40_000 {
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

