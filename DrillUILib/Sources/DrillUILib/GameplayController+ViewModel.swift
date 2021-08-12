//
//  GameplayController+ViewModel.swift
//
//
//  Created by Paul on 8/13/21.
//

import Foundation
//import Combine


extension GameplayController {
    public final class ViewModel: ObservableObject {

        @Published public var displayField: DisplayField

        init(displayField: DisplayField) {
            self.displayField = displayField
        }
    }
}

