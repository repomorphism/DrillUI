//
//  ContentView.swift
//
//
//  Created by Paul on 8/4/21.
//

import SwiftUI
import DrillUILib


struct ContentView: View {

    @EnvironmentObject var controller: GameplayController

//    @State private var outputs: [ConsoleOutput] = []

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack {
                GameView(viewModel: controller.viewModel)
                Spacer(minLength: 0)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            Spacer(minLength: 0)
            ControlView(controlAction: handleControlAction,
                        legalMoves: controller.legalMoves)
                .frame(width: 300)
                .background(.black)
                .foregroundColor(.init(white: 0.9))
//            ConsoleView(outputs: outputs)
//                .frame(width: 300)
//                .foregroundColor(.init(white: 0.9))
        }
        .background(Color(white: 0.05))
        .ignoresSafeArea()
//        .onAppear {
//            outputs.append(contentsOf: [
//                ConsoleOutput("New Game!"),
//                ConsoleOutput(controller.field.debugDescription)])
//        }
    }
}

private extension ContentView {
    func handleControlAction(_ action: ControlView.ActionType) {
        switch action {
        case .newGame(let count):
            controller.startNewGame(garbageCount: count)
//            outputs = [ConsoleOutput("New Game!"), ConsoleOutput(controller.field.debugDescription)]

        case .botStartThinking:
            controller.startThinking()

        case .play(let piece):
            controller.play(piece)

        case .botStopThinking:
            controller.stopThinking()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
