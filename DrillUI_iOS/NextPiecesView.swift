//
//  NextPiecesView.swift
//  NextPiecesView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI

struct NextPiecesView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.clear)
                .aspectRatio(4 / 20, contentMode: .fit)
                .padding(2)
                .layoutPriority(1)
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .aspectRatio(4 / 15, contentMode: .fit)
                    .border(Color(white: 0.75), width: 1.0)
                    .padding(1)
                // VStack { // 5 preview pieces }
            }
        }
    }
}

struct PreviewPiecesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NextPiecesView()
                .background(Color(white: 0.05))
            Spacer()
        }
            .frame(width: 300, height: 1000)
            .background(Color(white: 0.25))
//            .previewLayout(.sizeThatFits)
    }
}
