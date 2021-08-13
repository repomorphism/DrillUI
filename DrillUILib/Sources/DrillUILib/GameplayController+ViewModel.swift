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

        @Published public var displayField: DisplayField
        @Published public var playPiece: Piece?

        init(displayField: DisplayField) {
            self.displayField = displayField
        }
    }
}

