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
        let newDisplayField = trueDisplayField.nextDisplayField(placing: piece, matching: newState.field)
        let newPlayPiece = Piece(type: newState.playPieceType, x: 4, y: 18, orientation: .up)

        trueDisplayField = newDisplayField
        let indicesChanged = trueDisplayField.reIndexRows()

        // First the play piece is dropped and gone, merged with the field.
        // The hold piece might've been swapped out.
        // A special case is when hold was empty, we're holding the play piece
        // and dropping the first piece in the preview.  In this situation,
        // more work is needed to manually show the interim preview next pieces.
        if hold == nil, newState.hold != nil {
            let intermediateNextPieceTypes = [nextPieceTypes[1]] + newState.nextPieceTypes.dropLast()
            enqueue(.setNextPieceTypes(intermediateNextPieceTypes))
        }
        enqueue(.setDropCount(newState.dropCount))
        enqueue(.setHold(newState.hold))
        enqueue(.setPlayPiece(nil))

        if indicesChanged {
            // Indices changed means that there is a line clear to animate
            // Setting the new field triggers a row-blowing animation
            enqueue(.setDisplayField(newDisplayField), delay: Constant.Timing.lineHanging)

            // After a short hang, get ready to play next piece
            enqueue(.setPlayPiece(newPlayPiece))
            enqueue(.setNextPieceTypes(newState.nextPieceTypes))

            // ...and clamp rows at the same time
            enqueue(.setDisplayField(trueDisplayField), delay: Constant.Timing.lineClamping)
        } else {
            // No line clear, no animation except a little pause
            enqueue(.setPlayPiece(newPlayPiece))
            enqueue(.setNextPieceTypes(newState.nextPieceTypes))
            enqueue(.setDisplayField(trueDisplayField), delay: Constant.Timing.setPiece)
        }
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

