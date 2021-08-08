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
        VStack(spacing: 0) {
            ForEach(field.rows) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< row.cells.count) { i in
                        MinoCellView(type: row.cells[i])
                    }
//                    .transition(.identity)
                }
            }
//            .transition(.identity)
//            .transition(.asymmetric(insertion: .identity, removal: .opacity))
            
//            .transition(.offset(.init(width: 0, height: 50)).animation(.spring()))
        }
//        .animation(.interpolatingSpring(stiffness: 50, damping: 10, initialVelocity: 10), value: field)

//        .animation(.easeIn(duration: 3).delay(1), value: field)
    }
}

struct FieldRowsView_Previews: PreviewProvider {
    static let storage: [Int16] = [0b11111_01111, 0b11011_11111, 0b11111_11101]
    static var previews: some View {
        FieldRowsView(field: DisplayField(from: Field(storage: storage, garbageCount: 3)))
            .aspectRatio(0.5, contentMode: .fit)
            .background(Color(white: 0.05))
    }
}
