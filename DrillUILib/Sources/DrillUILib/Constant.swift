//
//  Constant.swift
//
//
//  Created by Paul on 8/15/21.
//

import Foundation


public enum Constant {
    public enum Timing {
        // Give it 2 frames for setting a piece on field, both when it clears
        // lines and when it doesn't not
        public static var setPiece: Double = 2/60
        // Line "blow up"
        public static var lineClearing: Double = 0.5
        // Wait time until clamping
        public static var lineHanging: Double = 0.25
        // Remove empty spaces
        public static var lineClamping: Double = 0.125
    }
}

