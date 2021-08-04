//
//  FieldCellsView.swift
//  FieldCellsView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI

struct FieldCellsView: View {
    let field: DisplayField

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< field.rows.count) { j in
                HStack(spacing: 0) {
                    ForEach(0 ..< field.rows[j].count) { i in
                        cell(i, j)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cell(_ i: Int, _ j: Int) -> some View {
        switch field.rows[j][i] {
        case .none:
            Color.clear
        case .garbage:
            Rectangle()
                .fill(cellColor(i, j))
                .cornerRadius(2)
                .padding(1)
                .background(cellSecondaryColor(i, j))
                .cornerRadius(2)
        }
    }

    private func cellColor(_ i: Int, _ j: Int) -> Color {
        switch field.rows[j][i] {
        case .none:
            return .clear
        case .garbage:
            return .gray
        }
    }

    private func cellSecondaryColor(_ i: Int, _ j: Int) -> Color {
        switch field.rows[j][i] {
        case .none:
            return .clear
        case .garbage:
            return .gray.opacity(0.8)
        }
    }
}

struct FieldCellsView_Previews: PreviewProvider {
    static let storage: [Int16] = [0b11111_01111, 0b11011_11111, 0b11111_11101]
    static var previews: some View {
        FieldCellsView(field: DisplayField(fieldStorage: storage))
            .aspectRatio(0.5, contentMode: .fit)
            .background(Color(white: 0.05))
    }
}
