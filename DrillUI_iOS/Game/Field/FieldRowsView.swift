//
//  FieldRowsView.swift
//  FieldRowsView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillUILib
import DrillAI


struct FieldRowsView: View {

    @State private var fieldHeight: CGFloat = 0

    let field: DisplayField

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .overlay(GeometryReader { proxy in
                    Color.clear
                        .preference(key: FieldHeightPreferenceKey.self,
                                    value: proxy.size.height)
                })
                .onPreferenceChange(FieldHeightPreferenceKey.self) { height in
                    fieldHeight = height
                }
            ForEach(Array(field.rows.enumerated()), id: \.1.id) { (index, row) in
                HStack(spacing: 0) {
                    ForEach(0 ..< row.cells.count) { i in
                        MinoCellView(type: row.cells[i])
                            .transition(.identity)
                    }
                }
                .aspectRatio(10, contentMode: .fit)
                .transition(.identity)
                .opacity(row.isFilled ? 0 : 1)
                .scaleEffect(row.isFilled ? 1.1 : 1)
                .blur(radius: row.isFilled ? 16 : 0)
                .offset(x: 0, y: fieldHeight * CGFloat(index) / 20)
            }
        }
        .animation(.easeIn(duration: 0.125), value: field)
    }
}


private struct FieldHeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
