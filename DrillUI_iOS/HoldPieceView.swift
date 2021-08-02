//
//  HoldPieceView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI

struct HoldPieceView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color(white: 0.75), lineWidth: 1.0)
                .padding(1)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

struct HoldPieceView_Previews: PreviewProvider {
    static var previews: some View {
        HoldPieceView()
    }
}
