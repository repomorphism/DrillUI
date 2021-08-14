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

        init(state: GameState) {
            reset(to: state)
        }
    }
}


public extension GameplayController.ViewModel {
    func reset(to state: GameState) {
        displayField = DisplayField(from: state.field)
        playPiece = Piece(type: state.playPieceType, x: 4, y: 18, orientation: .up)
        hold = state.hold
        nextPieceTypes = state.nextPieceTypes
    }

    func update(newState: GameState, placed piece: Piece) async {
        var newDisplayField = displayField.nextDisplayField(placing: piece, matching: newState.field)
        let newPlayPiece = Piece(type: newState.playPieceType, x: 4, y: 18, orientation: .up)
        await set(hold: newState.hold)
        await set(dropCount: newState.dropCount)
        if let normalizedField = newDisplayField.normalizedDisplayField() {
            // Animate line clear
            // Set all rows as not filled first before animation
            let clearedRowIndices = (0 ..< newDisplayField.rows.count).filter { newDisplayField.rows[$0].isFilled }
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = false }
            await set(displayField: newDisplayField, playPiece: nil)
            await Task.sleep(10_000_000)

            // Animate row clears (in-place)
            clearedRowIndices.forEach { newDisplayField.rows[$0].isFilled = true }
            await set(displayField: newDisplayField, playPiece: nil)
            await Task.sleep(125_000_000)

            // Animate row rearrangement
            await set(nextPieceTypes: newState.nextPieceTypes)
            await set(displayField: normalizedField, playPiece: newPlayPiece)
            await Task.sleep(125_000_000)
        } else {
            // No line clear (so normalizing returns nil)
            await set(nextPieceTypes: newState.nextPieceTypes)
            await set(displayField: newDisplayField, playPiece: newPlayPiece)
        }
    }
}

private extension GameplayController.ViewModel {
    @MainActor func set(displayField: DisplayField, playPiece: Piece?) {
        self.displayField = displayField
        self.playPiece = playPiece
    }

    @MainActor func set(hold: Tetromino?) {
        self.hold = hold
    }

    @MainActor func set(nextPieceTypes: [Tetromino]) {
        self.nextPieceTypes = nextPieceTypes
    }

    @MainActor func set(dropCount: Int) {
        self.dropCount = dropCount
    }
}

