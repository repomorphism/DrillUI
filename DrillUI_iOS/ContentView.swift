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
        ControlView(controller: controller)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background Color"))
    }

    var gameView: some View {
        GameView(viewModel: controller.viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color("Background Color"))
            .ignoresSafeArea()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
