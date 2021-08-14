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

    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now

    public init() {
        let state = GameState(garbageCount: 6)
        let evaluator = BCTSEvaluator()
        self.viewModel = ViewModel(state: state)
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)
        defer {
            Task { await updateLegalMoves() }
        }
    }
}


public extension GameplayController {
    func startNewGame(garbageCount count: Int) {
        let state = GameState(garbageCount: count)
        let evaluator = BCTSEvaluator()
        viewModel.reset(to: state)
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        Task { await updateLegalMoves() }
    }

    func startThinking() {
        bot.startThinking()
        thinkingStartTime = .now
        startTimer()
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
            } else {
                await updateLegalMoves()
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
        guard legalMoves.count > 0 else { return false }

        // Condition 0: Bot has stopped thinking
        if !bot.isThinking {
            return true
        }

        // Condition 1: Thought for over 5 seconds
        if thinkingStartTime.timeIntervalSinceNow < -5 {
            return true
        }

        // Condition 2: 20k total including some "decisiveness" bonus
        let totalN = legalMoves.map(\.visits).reduce(0, +)
        let topVisits = legalMoves[0].visits
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
                // Before the view model could handle animation queue, give it time
                // for line clear animation
                await Task.sleep(250_000_000)
                play(topAction, resumeThinkingAfterPlay: true)
            }
        }
    }

    func startTimer() {
        timerSubscription = Timer.publish(every: 0.3, on: .main, in: .common)
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

