//
//  NextPiecesView.swift
//  NextPiecesView
//
//  Created by Paul on 8/3/21.
//

import SwiftUI

struct NextPiecesView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color(white: 0.75), lineWidth: 1.0)
                .padding(1)
        }
        .aspectRatio(4 / 15, contentMode: .fit)
    }
}

struct PreviewPiecesView_Previews: PreviewProvider {
    static var previews: some View {
        NextPiecesView()
    }
}
