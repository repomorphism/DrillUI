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

    var body: some View {
        NavigationView {
            controlView
                .navigationTitle("DrillUI")
            gameView
        }
    }

    var controlView: some View {
        ControlView(controlAction: handleControlAction,
                    legalMoves: controller.legalMoves,
                    isBotActive: controller.isActive)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(.black)
//            .background(Color.init(white: 0.9))
//            .foregroundColor(.init(white: 0.9))
    }

    var gameView: some View {
        GameView(viewModel: controller.viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
//            .background(Color.init(white: 0.9))
//            .background(Color(white: 0.05))
            .ignoresSafeArea()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
