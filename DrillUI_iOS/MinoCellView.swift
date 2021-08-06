//
//  MinoCellView.swift
//  MinoCellView
//
//  Created by Paul on 8/5/21.
//

import SwiftUI
import DrillAI


struct MinoCellView: View {
    enum CellType: Equatable {
        case none
        case garbage
        case live(Tetromino)
        case placed(Tetromino)
    }

    let type: CellType

    var body: some View {
        switch type {
        case .none:
            Color.clear
        case .garbage, .live(_):
            Rectangle()
                .fill(cellColor)
                .cornerRadius(2)
                .padding(1)
                .background(cellSecondaryColor)
                .cornerRadius(2)
        case .placed(_):
            Rectangle()
                .fill(cellColor)
                .cornerRadius(2)
                .padding(1)
                .background(cellSecondaryColor)
                .cornerRadius(2)
                .saturation(0.6)    // Same, just desaturated
        }
    }

    private var cellColor: Color {
        switch type {
        case .none:
            return .clear
        case .garbage:
            return .gray
        case .live(let tetromino):
            return tetromino.placedMinoColor
        case .placed(let tetromino):
            return tetromino.placedMinoColor
        }
    }

    private var cellSecondaryColor: Color {
        switch type {
        case .none:
            return .clear
        case .garbage:
            return .gray.opacity(0.8)
        case .live(let tetromino):
            return tetromino.placedMinoColor.opacity(0.8)
        case .placed(let tetromino):
            return tetromino.placedMinoColor.opacity(0.8)
        }
    }
}

extension Tetromino {
    var placedMinoColor: Color {
        switch self {
        case .I:
            return .cyan
        case .J:
            return .blue
        case .L:
            return .orange
        case .O:
            return .yellow
        case .S:
            return .green
        case .T:
            return .purple
        case .Z:
            return .red
        }
    }
}

struct MinoCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MinoCellView(type: .garbage)
            MinoCellView(type: .none)
        }
    }
}
