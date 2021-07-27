//
//  ControlView.swift
//  ControlView
//
//  Created by Paul on 7/28/21.
//

import SwiftUI


struct ControlView: View {
    enum ActionType {
        case newGame
        case step
    }

    let controlAction: (ActionType) -> Void
    var body: some View {
        VStack(spacing: 20) {
            Button("New Game") { controlAction(.newGame) }
            .padding()
            Button("Step") { controlAction(.step) }
            .padding()
        }
    }

    init(_ controlAction: ((ActionType) -> Void)? = nil) {
        self.controlAction = controlAction ?? { _ in }
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}
