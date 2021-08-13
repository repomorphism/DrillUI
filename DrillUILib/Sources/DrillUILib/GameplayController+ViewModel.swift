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

}

