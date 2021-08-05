//
//  DisplayField.swift
//
//
//  Created by Paul on 8/3/21.
//

import Foundation
import DrillAI


struct DisplayField {
    typealias CellType = MinoCellView.CellType

    struct Row: Identifiable {
        let id: UUID = .init()
        var cells: [CellType]

        init(bitmap: Int16) {
            self.cells = (0 ..< 10).map { i -> CellType in
                bitmap & (1 << i) == 0 ? .none : .garbage
            }
        }

        var isFilled: Bool { !cells.contains(.none) }
        var isEmpty: Bool { cells.allSatisfy { $0 == .none } }
    }

    let rows: [Row]

    // These rows are top-down, opposite of Field's bottom-up

    init() {
        self.init(fieldStorage: [])
    }

    init(rows: [Row]) {
        self.rows = rows
    }

    init(from field: Field) {
        assert(field.storage.count <= 20)
        self.init(fieldStorage: field.storage)
    }

    init(fieldStorage: [Int16]) {
        assert(fieldStorage.count <= 20)
        // Fill to 20 rows
        let filledStorage = [Int16](repeating: 0, count: 20 - fieldStorage.count) + fieldStorage.reversed()
        self.rows = filledStorage.map(Row.init(bitmap:))
    }

    /// Parallels `Field.lockDown(_)`, due to Field not keeping info about
    /// original tetromino
    func nextDisplayField(placing piece: Piece, matching field: Field) -> DisplayField {
        var newRows = rows
        let cellPositions = piece.cellPositions
        for (x, y) in cellPositions {
            newRows[19 - y].cells[x] = .placed(piece.type)
        }

        // Remove filled rows
        let lowestRow = cellPositions.map(\.y).min()!
        let highestRow = cellPositions.map(\.y).max()!

        var removedRowCount = 0
        for rowIndex in (lowestRow ... highestRow) {
            if newRows[19 - rowIndex].isFilled {
                newRows.remove(at: 19 - rowIndex)
                removedRowCount += 1
            }
        }

        // Find current height, or highest nonempty row
        var highestNonemptyRow = highestRow - removedRowCount
        while !newRows[(newRows.count - 1) - (highestNonemptyRow + 1)].isEmpty {
            highestNonemptyRow += 1
        }

        // Compare to matching field to see how many garbage lines are added
        let risenRowCount = field.height - (highestNonemptyRow + 1)
        let risenRows = field.storage.prefix(risenRowCount).reversed()

        // Calculate how many top empty rows to be added
        let emptyRowCount = 20 - newRows.count - risenRowCount

        // Put together empty rows - existing rows - risen garbage
        newRows = (0 ..< emptyRowCount).map { _ in Row(bitmap: 0) }
            + newRows
            + risenRows.map { Row(bitmap: $0) }

        return DisplayField(rows: newRows)
    }
}
