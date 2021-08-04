//
//  DisplayField.swift
//
//
//  Created by Paul on 8/3/21.
//

import Foundation
import DrillAI


struct DisplayField {
    enum Cell {
        case none
        case garbage
    }
    let rows: [[Cell]]

    init(from field: Field) {
        assert(field.storage.count <= 20)
        self.init(fieldStorage: field.storage)
    }

    init(fieldStorage: [Int16]) {
        assert(fieldStorage.count <= 20)
        let filledStorage = [Int16](repeating: 0, count: 20 - fieldStorage.count) + fieldStorage.reversed()
        self.rows = filledStorage.map { (line: Int16) -> [Cell] in
            (0 ..< 10).map { i -> Cell in
                line & (1 << i) == 0 ? .none : .garbage
            }
        }
    }
}
