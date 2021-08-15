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
        // A full line clear have two stages, so it takes double this many seconds
        public static var lineClear: Double = 0.125
    }

    // Colors go here
}

