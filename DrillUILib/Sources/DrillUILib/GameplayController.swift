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

    public let viewModel: ViewModel = .init()

    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now
    private var shouldBeThinking: Bool = false

    public init() {
        let state = GameState(garbageCount: 6)
        viewModel.reset(to: state)
        self.bot = GeneratorBot(initialState: state, evaluator: BCTSEvaluator())
        Task { await updateLegalMoves() }
    }
}


public extension GameplayController {
    func startNewGame(garbageCount count: Int) {
        let state = GameState(garbageCount: count)
        viewModel.reset(to: state)
        bot = GeneratorBot(initialState: state, evaluator: BCTSEvaluator())
        Task { await updateLegalMoves() }
    }

    func startThinking() {
        shouldBeThinking = true
        startBotAndTimer()
    }

    func stopThinking() {
        shouldBeThinking = false
        stopBotAndTimer()
    }

    func play(_ piece: Piece) {
        stopBotAndTimer()

        Task {
            let newState = await bot.advance(with: piece)
            await updateLegalMoves()
            if legalMoves.count == 0 {
                shouldBeThinking = false
            }
            if shouldBeThinking {
                startBotAndTimer()
            }
            await viewModel.update(newState: newState, placed: piece)
        }
    }
}


private extension GameplayController {
    func startBotAndTimer() {
        bot.startThinking()
        thinkingStartTime = .now
        timerSubscription = Timer.publish(every: 0.3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.performAutoplay()
            }
    }

    func stopBotAndTimer() {
        bot.stopThinking()
        timerSubscription = nil
    }

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
            stopBotAndTimer()
            Task {
                await updateLegalMoves()
                // Before the view model could handle animation queue, give it time
                // for line clear animation, and user might get a climpse of the
                // action list
                await Task.sleep(250_000_000)
                let topAction = legalMoves[0].action
                play(topAction)
            }
        } else {
            Task {
                await updateLegalMoves()
            }
        }
    }
}

