//
//  PieceUtilities.swift
//  PieceUtilities
//
//  Created by Paul on 8/5/21.
//

import Foundation
import DrillAI

/*
 Borrowing logic from BombStepper-iOS for the displaying side of field/piece
 */


public extension Piece {
    typealias Offset = (x: Int, y: Int)
    typealias CellPosition = (x: Int, y: Int)

    var cellPositions: [CellPosition] {
        blockOffsets.map { offset in
            (x: x + offset.x, y: y + offset.y)
        }
    }
}

private extension Piece {
    var blockOffsets: [Offset] {
        let matrix = orientation.rotationMatrix

        return initialBlockOffsets.map { offset in
            (x: matrix.0 * offset.x + matrix.1 * offset.y,
             y: matrix.2 * offset.x + matrix.3 * offset.y)
        }
    }

    /// This defines the shape of the tetromino in its initial orientation,
    /// by specifying its four minos in terms of their offsets from the center mino
    var initialBlockOffsets: [Offset] {
        switch type {
        case .I: return [(0, 0), (-1, 0), ( 1, 0), (2, 0)]
        case .J: return [(0, 0), (-1, 1), (-1, 0), (1, 0)]
        case .L: return [(0, 0), (-1, 0), ( 1, 0), (1, 1)]
        case .O: return [(0, 0), ( 0, 1), ( 1, 1), (1, 0)]
        case .S: return [(0, 0), (-1, 0), ( 0, 1), (1, 1)]
        case .T: return [(0, 0), (-1, 0), ( 1, 0), (0, 1)]
        case .Z: return [(0, 0), (-1, 1), ( 0, 1), (1, 0)]
        }
    }
}

private extension Piece.Orientation {
    var rotationMatrix: (Int, Int, Int, Int) {
        switch self {
        case .up: return (1, 0, 0, 1)
        case .right: return (0, 1, -1, 0)
        case .down: return (-1, 0, 0, -1)
        case .left: return (0, -1, 1, 0)
        }
    }
}

