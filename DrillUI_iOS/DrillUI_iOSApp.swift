//
//  DrillAI_iOSApp.swift
//  DrillAI-iOS
//
//  Created by Paul on 7/28/21.
//

import SwiftUI
import DrillAI


typealias ActionVisits = MCTSTree<GameState>.ActionVisits

private let initialGameLength = 10

@main
struct DrillAI_iOSApp: App {

    private let controller: GameplayController

    init() {
        self.controller = GameplayController()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
        }
    }
}


