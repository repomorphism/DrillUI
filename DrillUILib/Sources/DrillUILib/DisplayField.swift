//
//  DisplayField.swift
//
//
//  Created by Paul on 8/3/21.
//

import Foundation
import DrillAI


public struct DisplayField {
    public let field: Field
    public var rows: [Row]
}


extension DisplayField {
    public enum CellType: Equatable {
        case none
        case garbage
        case live(Tetromino)
        case ghost(Tetromino)
        case placed(Tetromino)
    }

    public struct Row: Identifiable, Equatable {
        public let id: UUID = .init()
        public var index: Int
        public var cells: [CellType]
        public var isFilled: Bool = false
    }
}


public extension DisplayField {
    init() {
        self.init(field: Field(), rows: [])
    }

    init(from field: Field) {
        self.rows = field.storage.enumerated().map { Row.init(bitmap:$1, index: $0) }
        self.field = field
    }

    /// Parallels `Field.lockDown(_)`, due to Field not keeping info about the
    /// original tetromino.  Returns a display field with the piece locked down,
    /// but not removing filled rows.  Look at `normalizedDisplayField()` to see
    /// if there's any row insertion/removal.
    func nextDisplayField(placing piece: Piece, matching field: Field) -> DisplayField {
        // Make a copy of rows and fill in the piece
        var newRows = rows.filter { !$0.isFilled }

        let cellPositions = piece.cellPositions
        let rowIndices = Set(cellPositions.map(\.y))
        let highestRow = rowIndices.max()!

        // Add just enough empty rows
        while newRows.count <= highestRow {
            newRows.append(Row(bitmap: 0, index: newRows.count))
        }

        for (x, y) in cellPositions {
            newRows[y].cells[x] = .placed(piece.type)
        }

        // Row-filled check, which also updates the rows themselves
        let filledRowsCount = rowIndices.filter { newRows[$0].checkFilled() }.count

        // Compare to matching field to see how many garbage lines are added
        let risenRowCount = field.height - newRows.count + filledRowsCount
        if risenRowCount > 0 {
            let risenRows = Array(field.storage.prefix(risenRowCount))
                .enumerated()
                .map {
                    Row(bitmap: $1, index: $0 - risenRowCount)
                }

            // Put together existing rows and risen garbage
            newRows = risenRows + newRows
        }

        return DisplayField(field: field, rows: newRows)
    }

    @discardableResult
    mutating func reIndexRows() -> Bool {
        var indexChanged = false
        var index = 0
        for i in 0 ..< rows.count {
            if !rows[i].isFilled {
                if rows[i].index != index {
                    rows[i].index = index
                    indexChanged = true
                }
                index += 1
            }
        }
        return indexChanged
    }
}


extension DisplayField.Row {
    init(bitmap: Int16, index: Int) {
        self.cells = (0 ..< 10).map { i -> DisplayField.CellType in
            bitmap & (1 << i) == 0 ? .none : .garbage
        }
        self.index = index
    }

    /// Check whether the row is filled, update its own status, and return the
    /// value as a convenience
    @discardableResult
    mutating func checkFilled() -> Bool {
        isFilled = !cells.contains(.none)
        return isFilled
    }
}


extension DisplayField: Equatable {}
