//
//  ControlView.swift
//  ControlView
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillUILib
import DrillAI


struct ControlView: View {

    @ObservedObject var controller: GameplayController

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Button("New Game (10)") { controller.startNewGame(garbageCount: 10) }
                Button("New Game (18)") { controller.startNewGame(garbageCount: 18) }
                startStopButton
                    .padding()
                HStack {
                    stepBackwardButton
                    stepText
                    stepForwardButton
                }
            }

            ScrollView {
                VStack {
                    ForEach(controller.legalMoves, id: \.action.code, content: moveButton)
                }
                .font(.system(.body, design: .monospaced))
                .padding()
            }
        }
    }
}


private extension ControlView {
    private var startStopButton: some View {
        Button {
            if controller.isActive {
                controller.stopThinking()
            } else {
                controller.startThinking()
            }
        } label: {
            Image(systemName: controller.isActive ? "stop.fill" : "play.fill")
                .foregroundColor(controller.isActive ? .red : .green)
                .font(.system(size: 48))
        }
    }

    private var stepBackwardButton: some View {
        Button {
            controller.stepBackward()
        } label: {
            Image(systemName: "arrowtriangle.backward")
                .font(.system(size: 32))
                .frame(maxWidth: .infinity)
        }
        .disabled(!controller.canStepBackward)
    }

    private var stepText: some View {
        Text("\(controller.step)")
            .font(.system(size: 24))
            .frame(maxWidth: .infinity)
    }

    private var stepForwardButton: some View {
        Button {
            controller.stepForward()
        } label: {
            Image(systemName: "arrowtriangle.forward")
                .font(.system(size: 32))
                .frame(maxWidth: .infinity)
        }
        .disabled(!controller.canStepForward)
    }

    private func moveButton(actionVisits: ActionVisits) -> some View {
        Button {
            controller.play(actionVisits.action)
        } label: {
            HStack {
                Text("\(actionVisits.visits)")
                Text(actionVisits.action.debugDescription)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("Game Blocks Border"), lineWidth: 1))
                    .cornerRadius(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(2)
    }
}


extension MCTSTree.ActionVisits: Equatable where State == GameState {
    public static func == (lhs: MCTSTree.ActionVisits, rhs: MCTSTree.ActionVisits) -> Bool {
        lhs.action == rhs.action && lhs.visits == rhs.visits
    }
}


struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView(controller: GameplayController())
    }
}
