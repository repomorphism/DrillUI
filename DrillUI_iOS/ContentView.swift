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
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack {
                GameView(viewModel: controller.viewModel)
                Spacer(minLength: 0)
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            Spacer(minLength: 0)
            ControlView(controller: controller)
                .frame(width: 300)
                .background(.black)
                .foregroundColor(.init(white: 0.9))
        }
        .background(Color(white: 0.05))
        .ignoresSafeArea()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
