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
    @Published public var isActive: Bool = false
    public var step: Int { recorder.step }
    public var canStepForward: Bool {
        !recorder.isAtLastStep
    }
    public var canStepBackward: Bool {
        recorder.step > 0
    }

    public let viewModel: ViewModel = .init()

    private var bot: GeneratorBot<DrillModelEvaluator>
    private let evaluator: DrillModelEvaluator = {
        // Issue getting the right location of the ML model, need to specify
        // subdirectory
        let modelURL = Bundle(for: DrillModelEvaluator.self)
            .url(forResource: "DrillModelCoreML",
                 withExtension: "mlmodelc",
                 subdirectory: "DrillAI_DrillAI.bundle")!
        return try! DrillModelEvaluator(modelURL: modelURL)
    }()

    private var recorder: GameRecorder
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now

    public init() {
        let state = GameState(garbageCount: 6, slidesAndTwists: false)
        viewModel.reset(to: state)
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)
        self.recorder = GameRecorder(initialState: state)
        Task { await updateLegalMoves() }
    }
}


public extension GameplayController {
    func startNewGame(garbageCount count: Int) {
        stopThinking()

        let state = GameState(garbageCount: count, slidesAndTwists: false)
        viewModel.reset(to: state)
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        recorder = GameRecorder(initialState: state)
        Task { await updateLegalMoves() }
    }

    func startThinking() {
        guard !legalMoves.isEmpty else { return }
        isActive = true
        startBotAndTimer()
    }

    func stopThinking() {
        isActive = false
        stopBotAndTimer()
    }

    func play(_ piece: Piece) {
        stopBotAndTimer()

        Task {
            let newState = await bot.advance(with: piece)
            recorder.log(searchResult: legalMoves, action: piece, newState: newState)

            await updateLegalMoves()
            if isActive {
                startBotAndTimer()
            }
            viewModel.update(newState: newState, placed: piece)
        }
    }

    func stepForward() {
        stopThinking()
        if let snapshot = recorder.stepForward() {
            updateWithSnapshot(snapshot)
        }
    }

    func stepBackward() {
        stopThinking()
        if let snapshot = recorder.stepBackward() {
            updateWithSnapshot(snapshot)
        }
    }
}


private extension GameplayController {
    func updateWithSnapshot(_ snapshot: (state: GameState, searchResult: [ActionVisits]?)) {
        let state = snapshot.state
        viewModel.reset(to: state)
        bot = GeneratorBot(initialState: state, evaluator: evaluator)
        if let legalMoves = snapshot.searchResult {
            self.legalMoves = legalMoves
        } else {
            Task { await updateLegalMoves() }
        }
    }

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
            if isActive && legalMoves.isEmpty {
                isActive = false
            }
        }
    }

    func shouldAutoplay() -> Bool {
        guard !legalMoves.isEmpty else { return false }

        // Condition 0: Bot has stopped thinking
        if !bot.isThinking {
            return true
        }

        // Condition 1: Thought for over 5 seconds
        if thinkingStartTime.timeIntervalSinceNow < -5 {
            return true
        }

        // Condition 2: Thought "enough," bonus for "decisiveness"
        let totalN = legalMoves.map(\.visits).reduce(0, +)
        let topVisits = legalMoves[0].visits
        let ratio = Double(topVisits) / Double(totalN + 1)
        let bonus = Int(max(0, ratio - 0.5) * Double(topVisits))

        if totalN + bonus > 10_000 {
            return true
        }

        return false
    }

    func performAutoplay() {
        if shouldAutoplay() {
            stopBotAndTimer()
            Task {
                await updateLegalMoves()
                // Recheck assumption; auto play is part of "thinking"
                if isActive {
                    let topAction = legalMoves[0].action
                    play(topAction)
                }
            }
        } else {
            Task {
                await updateLegalMoves()
            }
        }
    }
}

