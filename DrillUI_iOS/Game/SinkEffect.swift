//
//  SinkEffect.swift
//
//
//  Created by Paul on 8/14/21.
//

import SwiftUI


struct SinkEffect: AnimatableModifier {
    var sinkNumber: CGFloat = 0
    let maxDepth: CGFloat = 3

    var animatableData: CGFloat {
        get {
            sinkNumber
        } set {
            sinkNumber = newValue
        }
    }

    private func timing(_ x: CGFloat) -> CGFloat {
        // Cubic ease in/out in 3 parts
        if x < 0.4 {
            let scaledX = 1 - (x / 0.4)
            return 1 - scaledX * scaledX * scaledX
        }
        if x < 0.7 {
            let scaledX = (x - 0.4) / 0.3
            return 0.5 + 0.5 * (1 - scaledX * scaledX * scaledX)
        }
        else { // 0.7 ~ 1.0
            let scaledX = (1 - x) / 0.3
            return 0.5 * scaledX * scaledX * scaledX
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(y: maxDepth * timing(sinkNumber.truncatingRemainder(dividingBy: 1)))
    }
}

extension View {
    func sinkEffect(sinkNumber: CGFloat) -> some View {
        self.modifier(SinkEffect(sinkNumber: sinkNumber))
    }
}
