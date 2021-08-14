//
//  GameView.swift
//
//
//  Created by Paul on 8/3/21.
//

import SwiftUI
import DrillUILib


struct GameView: View {

    @ObservedObject var viewModel: GameplayController.ViewModel

    @State private var dropCount: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer(minLength: 0)
            HoldPieceView(type: viewModel.hold)
            Spacer(minLength: 0)
            FieldView(displayField: viewModel.displayField, playPiece: viewModel.playPiece)
                .sinkEffect(sinkNumber: CGFloat(dropCount))
            Spacer(minLength: 0)
            NextPiecesView(nextPieceTypes: viewModel.nextPieceTypes)
            Spacer(minLength: 0)
        }
        // A 0.92 ratio is just about enough, extra widths go into spacers.
        // If not wide enough, one of them will shrink to incorrect size.
        .aspectRatio(0.925, contentMode: .fit)
        .onChange(of: viewModel.dropCount) { dropCount in
            if dropCount < self.dropCount {
                self.dropCount = dropCount
            } else {
                withAnimation(.easeOut(duration: 1)) {
                    self.dropCount = dropCount
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = GameplayController()
        GameView(viewModel: controller.viewModel)
            .background(Color(white: 0.05))
            .previewLayout(.sizeThatFits)
    }
}
