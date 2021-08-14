//
//  SinkEffect.swift
//
//
//  Created by Paul on 8/14/21.
//

import SwiftUI


struct SinkEffect: AnimatableModifier {
    var sinkNumber: CGFloat = 0
    let maxDepth: CGFloat = 4

    var animatableData: CGFloat {
        get {
            sinkNumber
        } set {
            sinkNumber = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(y: maxDepth * 2 * (0.5 - (sinkNumber.truncatingRemainder(dividingBy: 1) - 0.5).magnitude))
    }
}

extension View {
    func sinkEffect(sinkNumber: CGFloat) -> some View {
        self.modifier(SinkEffect(sinkNumber: sinkNumber))
    }
}
