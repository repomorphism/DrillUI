//
//  GameplayController+ViewModel.swift
//
//
//  Created by Paul on 8/13/21.
//

import Foundation
import DrillAI


extension GameplayController {
    public final class ViewModel: ObservableObject {
        @Published public var displayField: DisplayField = .init()
        @Published public var playPiece: Piece?
        @Published public var hold: Tetromino?
        @Published public var nextPieceTypes: [Tetromino] = []
        @Published public var dropCount: Int = 0

        /// This is the field's "source of truth" as the public-facing display
        /// field is updated over time so it may be consistent when a new
        /// updates come in before the last update sequence finishes.  The true
        /// state is set immediately on update, and update sequences always refer
        /// to the true state as the starting point.
        private var trueDisplayField: DisplayField = .init()
        private var availableTime: Date = .init()

        private let queue: OperationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .userInitiated
            return queue
        }()
    }
}


public extension GameplayController.ViewModel {
    func reset(to state: GameState) {
        queue.cancelAllOperations()
        trueDisplayField = DisplayField(from: state.field)
        enqueue(.setDisplayField(trueDisplayField))
        enqueue(.setPlayPiece(Piece(type: state.playPieceType, x: 4, y: 18, orientation: .up)))
        enqueue(.setHold(state.hold))
        enqueue(.setNextPieceTypes(state.nextPieceTypes))
    }

    func update(newState: GameState, placed piece: Piece) {
        var newDisplayField = trueDisplayField.nextDisplayField(placing: piece, matching: newState.field)
        enqueue(.setDisplayField(newDisplayField))
        
        newDisplayField.reIndexRows()
//        newDisplayField.removeFilledRows()
        trueDisplayField = newDisplayField

        let newPlayPiece = Piece(type: newState.playPieceType, x: 4, y: 18, orientation: .up)
        enqueue(.setHold(newState.hold))
//        enqueue(.setPlayPiece(nil))
        enqueue(.setDropCount(newState.dropCount))

//        if newDisplayField.reIndexRows() {
//            enqueue(.setDisplayField(newDisplayField))
//            newDisplayField.removeFilledRows()
//            enqueue(.setDisplayField(newDisplayField))
//        }
//        enqueue(.setDisplayField(newDisplayField))
        enqueue(.setPlayPiece(newPlayPiece))
        enqueue(.setNextPieceTypes(newState.nextPieceTypes), delay: Constant.Timing.lineClear)






//        if let normalizedField = newDisplayField.normalizedDisplayField() {
//            trueDisplayField = normalizedField
//            // Animate line clear
//            // Set all rows as not filled first before line clear animation
//            let clearedRowIndices = (0 ..< newDisplayField.rows.count).filter { newDisplayField.rows[$0].isFilled }
//            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = false }
//            enqueue(.setDisplayField(newDisplayField), delay: Constant.Timing.setPiece)
//
//            // Animate line clears (in-place)
//            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = true }
//            enqueue(.setDisplayField(newDisplayField), delay: Constant.Timing.lineClear)
//
//            // Animate row rearrangement, bring in next piece
//            enqueue(.setNextPieceTypes(newState.nextPieceTypes))
//            enqueue(.setPlayPiece(newPlayPiece))
//            enqueue(.setDisplayField(normalizedField), delay: Constant.Timing.lineClear)
//        } else {
//            trueDisplayField = newDisplayField
//            // No line clear (so normalizing returns nil)
//            enqueue(.setNextPieceTypes(newState.nextPieceTypes))
//            enqueue(.setPlayPiece(newPlayPiece))
//            enqueue(.setDisplayField(newDisplayField), delay: Constant.Timing.setPiece)
//        }
    }
}

private extension GameplayController.ViewModel {

    enum UpdateType {
        case setDisplayField(DisplayField)
        case setPlayPiece(Piece?)
        case setHold(Tetromino?)
        case setDropCount(Int)
        case setNextPieceTypes([Tetromino])
    }

    func enqueue(_ update: UpdateType, delay: Double = 0) {
        let action: () -> Void = {
            DispatchQueue.main.async {
                switch update {
                case .setDisplayField(let displayField):
                    self.displayField = displayField    // Capture self is okay
                case .setPlayPiece(let playPiece):
                    self.playPiece = playPiece
                case .setHold(let hold):
                    self.hold = hold
                case .setDropCount(let dropCount):
                    self.dropCount = dropCount
                case .setNextPieceTypes(let nextPieceTypes):
                    self.nextPieceTypes = nextPieceTypes
                }
            }
        }
        if availableTime <= .now {
            // Available now
            queue.addOperation(action)
            availableTime = .now + delay
        } else {
            // Available in the future
            queue.schedule(after: .init(availableTime), action)
            availableTime += delay
        }
    }
}

