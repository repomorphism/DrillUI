//
//  FieldView.swift
//
//
//  Created by Paul on 8/2/21.
//

import SwiftUI
import DrillAI


struct FieldView: View {
    let field: Field
    var body: some View {
        ZStack {
            GridLinesView()
                .padding(2)
            FieldCellsView(field: DisplayField(from: field))
                .padding(2)
            Rectangle()
                .strokeBorder(Color(white: 0.75), lineWidth: 2.0)
        }
        .aspectRatio(0.5, contentMode: .fit)
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(field: GameState(garbageCount: 8).field)
            .background(Color(white: 0.05))
//            .previewInterfaceOrientation(.landscapeRight)
            .previewLayout(.sizeThatFits)
    }
}
