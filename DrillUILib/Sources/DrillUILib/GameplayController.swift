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

    public let viewModel: ViewModel

    @Published public var legalMoves: [ActionVisits] = []

    private var state: GameState
    private var bot: GeneratorBot<BCTSEvaluator>
    private var timerSubscription: Cancellable?
    private var thinkingStartTime: Date = .now

    public init() {
        let state = GameState(garbageCount: 8)
        let evaluator = BCTSEvaluator()
        self.state = state
        self.legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        let displayField = DisplayField(from: state.field)
        self.bot = GeneratorBot(initialState: state, evaluator: evaluator)

        let viewModel = ViewModel(displayField: displayField)
        viewModel.playPiece = Piece(type: state.playPieceType, x: 4, y: 18, orientation: .up)
        viewModel.hold = state.hold
        viewModel.nextPieceTypes = state.nextPieceTypes
        self.viewModel = viewModel

        defer {
            self.bot.autoStopAction = { [weak self] in self?.handleBotAutoStop() }
        }
    }
}


public extension GameplayController {
    var field: Field {
        state.field
    }

    func startNewGame(garbageCount count: Int) {
        let newState = GameState(garbageCount: count)
        let evaluator = BCTSEvaluator()
        state = newState
        legalMoves = state.getLegalActions().map { ActionVisits(action: $0, visits: 0) }
        viewModel.displayField = DisplayField(from: state.field)
        viewModel.playPiece = Piece(type: state.playPieceType, x: 4, y: 18, orientation: .up)
        viewModel.hold = state.hold
        viewModel.nextPieceTypes = state.nextPieceTypes
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
            if resumeThinkingAfterPlay, legalMoves.count > 0 {
                startThinking()
            }
            // Bot state & controller is briefly mismatched
            await animatePlay(newState: newState, piece: piece)
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

    func animatePlay(newState: GameState, piece: Piece) async {
        var newDisplayField = viewModel.displayField.nextDisplayField(placing: piece, matching: newState.field)
        if let normalizedField = newDisplayField.normalizedDisplayField() {
            // Animate line clear
            // Set all rows as not filled first before animation
            let clearedRowIndices = (0 ..< newDisplayField.rows.count).filter { newDisplayField.rows[$0].isFilled }
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = false }
            await update(state: state, displayField: newDisplayField, playPieceType: nil)
            await Task.sleep(10_000_000)

            // Animate row clears (in-place)
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = true }
            await update(state: state, displayField: newDisplayField, playPieceType: nil)
            await Task.sleep(125_000_000)

            // Animate row rearrangement
            await update(state: newState, displayField: normalizedField, playPieceType: newState.playPieceType)
            await Task.sleep(125_000_000)
        } else {
            // No line clear (so normalizing returns nil)
            await update(state: newState, displayField: newDisplayField, playPieceType: newState.playPieceType)
        }

        await updateLegalMoves()

    }

    @MainActor
    func update(state: GameState, displayField: DisplayField, playPieceType: Tetromino?) {
        self.state = state
        viewModel.displayField = displayField
        viewModel.playPiece = playPieceType.map { Piece(type: $0, x: 4, y: 18, orientation: .up) }
        viewModel.hold = state.hold
        viewModel.nextPieceTypes = state.nextPieceTypes
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

