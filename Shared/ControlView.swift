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
                .padding()
                HStack {
                    Button {
                        controller.stepBackward()
                    } label: {
                        Image(systemName: "arrowtriangle.backward")
                            .font(.system(size: 32))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!controller.canStepBackward)

                    Text("\(controller.step)")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity)

                    Button {
                        controller.stepForward()
                    } label: {
                        Image(systemName: "arrowtriangle.forward")
                            .font(.system(size: 32))
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!controller.canStepForward)
                }
            }

            ScrollView {
                VStack {
                    ForEach(controller.legalMoves, id: \.action.code) { actionVisits in
                        Button {
                            controller.play(actionVisits.action)
                        } label: {
                            HStack {
                                Text("\(actionVisits.visits)")
                                Text(actionVisits.action.debugDescription)
                                    .frame(maxWidth: .infinity)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray, lineWidth: 1))
                                    .cornerRadius(16)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(2)
                    }
                }
                .font(.system(.body, design: .monospaced))
            }
        }
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
