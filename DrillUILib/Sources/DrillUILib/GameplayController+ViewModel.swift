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
        enqueue(.setDisplayField(DisplayField(from: state.field)))
        enqueue(.setPlayPiece(Piece(type: state.playPieceType, x: 4, y: 18, orientation: .up)))
        enqueue(.setHold(state.hold))
        enqueue(.setNextPieceTypes(state.nextPieceTypes))
    }

    func update(newState: GameState, placed piece: Piece) {
        var newDisplayField = displayField.nextDisplayField(placing: piece, matching: newState.field)
        let newPlayPiece = Piece(type: newState.playPieceType, x: 4, y: 18, orientation: .up)
        enqueue(.setHold(newState.hold))
        enqueue(.setDropCount(newState.dropCount))
        if let normalizedField = newDisplayField.normalizedDisplayField() {
            // Animate line clear
            // Set all rows as not filled first before line clear animation
            let clearedRowIndices = (0 ..< newDisplayField.rows.count).filter { newDisplayField.rows[$0].isFilled }
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = false }
            enqueue(.setPlayPiece(nil))
            enqueue(.setDisplayField(newDisplayField), delay: 1/60)

            // Animate line clears (in-place)
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = true }
            enqueue(.setDisplayField(newDisplayField), delay: 0.125)

            // Animate row rearrangement, bring in next piece
            enqueue(.setNextPieceTypes(newState.nextPieceTypes))
            enqueue(.setPlayPiece(newPlayPiece))
            enqueue(.setDisplayField(normalizedField), delay: 0.125)
        } else {
            // No line clear (so normalizing returns nil)
            enqueue(.setNextPieceTypes(newState.nextPieceTypes))
            enqueue(.setPlayPiece(newPlayPiece))
            enqueue(.setDisplayField(newDisplayField))
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
        queue.addOperation { [weak self] in
            DispatchQueue.main.async {
                switch update {
                case .setDisplayField(let displayField):
                    self?.displayField = displayField
                case .setPlayPiece(let playPiece):
                    self?.playPiece = playPiece
                case .setHold(let hold):
                    self?.hold = hold
                case .setDropCount(let dropCount):
                    self?.dropCount = dropCount
                case .setNextPieceTypes(let nextPieceTypes):
                    self?.nextPieceTypes = nextPieceTypes
                }
            }
            if delay > 0 {
                Thread.sleep(forTimeInterval: delay)
            }
        }
    }
}

