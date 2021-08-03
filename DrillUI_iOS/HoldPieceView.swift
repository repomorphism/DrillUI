//
//  HoldPieceView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillAI


struct HoldPieceView: View {
    let type: Tetromino?
    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color(white: 0.75), lineWidth: 1.0)
                .padding(1)
                .aspectRatio(1, contentMode: .fit)
            if let type = type {
                Text(type.debugDescription)
                    .font(.largeTitle)
                    .foregroundColor(.green)
            }
        }
    }
}

struct HoldPieceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HoldPieceView(type: .T)
                .background(Color(white: 0.05))
            Spacer()
        }
            .frame(width: 300, height: 1000)
            .background(Color(white: 0.25))
//            .previewLayout(.sizeThatFits)
    }
}
