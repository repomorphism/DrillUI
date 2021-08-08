//
//  DisplayField.swift
//
//
//  Created by Paul on 8/3/21.
//

import Foundation
import DrillAI


struct DisplayField {
    let field: Field
    let rows: [Row]     // These rows are top-down, opposite of Field's bottom-up
}


extension DisplayField {
    struct Row: Identifiable, Equatable {
        let id: UUID = .init()
        var cells: [MinoCellView.CellType]
    }
}


extension DisplayField {
    init(from field: Field) {
        // Fill to 20 rows
        let filledStorage = [Int16](repeating: 0, count: 20 - field.height) + field.storage.reversed()
        self.rows = filledStorage.map(Row.init(bitmap:))
        self.field = field
    }

    /// Parallels `Field.lockDown(_)`, due to Field not keeping info about the
    /// original tetromino.  Returns a display field with the piece locked down,
    /// but not removing filled rows.  Look at `normalizedDisplayField()` to see
    /// if there's any row insertion/removal.
    func nextDisplayField(placing piece: Piece, matching field: Field) -> DisplayField {
        // Make a copy of rows and fill in the piece
        var newRows = rows
        let cellPositions = piece.cellPositions
        for (x, y) in cellPositions {
            newRows[19 - y].cells[x] = .placed(piece.type)
        }

        // Count filled rows
        let lowestRow = cellPositions.map(\.y).min()!
        let highestRow = cellPositions.map(\.y).max()!

        var filledRowCount = 0
        for rowIndex in (lowestRow ... highestRow) {
            if newRows[19 - rowIndex].isFilled {
                filledRowCount += 1
            }
        }

        // Find current height, or highest nonempty row
        var highestNonemptyRow = highestRow
        while !newRows[(newRows.count - 1) - (highestNonemptyRow + 1)].isEmpty {
            highestNonemptyRow += 1
        }

        // Compare to matching field to see how many garbage lines are added
        let risenRowCount = field.height - (highestNonemptyRow + 1 - filledRowCount)
        let risenRows = field.storage.prefix(risenRowCount).reversed()

        // Put together existing rows and risen garbage
        newRows += risenRows.map { Row(bitmap: $0) }

        return DisplayField(field: field, rows: newRows)
    }

    /// Normalize the field by clearing filled rows and fill up to 20 rows if needed.
    /// Returns nil if no modification is necessary.
    func normalizedDisplayField() -> DisplayField? {
        var newRows = rows.filter { !$0.isFilled }
        guard newRows.count != rows.count || newRows.count != 20 else {
            return nil
        }

        if newRows.count < 20 {
            newRows = (newRows.count ..< 20).map { _ in Row(bitmap: 0) } + newRows
        }
        return DisplayField(field: field, rows: newRows)
    }
}


extension DisplayField.Row {
    init(bitmap: Int16) {
        self.cells = (0 ..< 10).map { i -> MinoCellView.CellType in
            bitmap & (1 << i) == 0 ? .none : .garbage
        }
    }

    var isFilled: Bool { !cells.contains(.none) }
    var isEmpty: Bool { cells.allSatisfy { $0 == .none } }
}


extension DisplayField: Equatable {}
