//
//  FieldRowsView.swift
//  FieldRowsView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct FieldRowsView: View {

    let field: DisplayField

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.clear)
                .aspectRatio(0.5, contentMode: .fit)
            ForEach(Array(field.rows.enumerated()), id: \.1.id) { (index, row) in
                HStack(spacing: 0) {
                    ForEach(0 ..< row.cells.count) { i in
                        MinoCellView(type: row.cells[i])
                            .transition(.identity)
                            .opacity(row.isFilled ? 0 : 1)
                    }
                }
                .aspectRatio(10, contentMode: .fit)
                .transition(.identity)
                .alignmentGuide(VerticalAlignment.top) { dimensions in
                    // Balance extra bottom rows with equal additional distance
                    -dimensions.height * CGFloat(index + (field.rows.count - 20))
                }
            }
        }
        .animation(.easeIn(duration: 0.3), value: field)
    }
//        .animation(.interpolatingSpring(stiffness: 50, damping: 10, initialVelocity: 10), value: field)

}

struct FieldRowsView_Previews: PreviewProvider {
    static let storage: [Int16] = [0b11111_01111, 0b11011_11111, 0b11111_11101]
    static var previews: some View {
        FieldRowsView(field: DisplayField(from: Field(storage: storage, garbageCount: 3)))
            .aspectRatio(0.5, contentMode: .fit)
            .background(Color(white: 0.05))
    }
}
