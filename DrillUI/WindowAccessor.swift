//
//  WindowAccessor.swift
//  WindowAccessor
//
//  Created by Paul on 7/28/21.
//

import SwiftUI


struct WindowAccessor: NSViewRepresentable {
    private func willMoveToWindow(newWindow: NSWindow) {
        // Do stuff to window
//        newWindow.contentView?.wantsLayer = true  // https://stackoverflow.com/questions/38986010/when-exactly-does-an-nswindow-get-rounded-corners
        newWindow.setContentSize(.init(width: 800, height: 600))
    }

    private class WindowAccessView: NSView {
        var willMoveToWindowAction: ((NSWindow?) -> Void)?
        override func viewWillMove(toWindow newWindow: NSWindow?) {
            willMoveToWindowAction?(newWindow)
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = WindowAccessView()
        view.willMoveToWindowAction = { newWindow in
            if let window = newWindow {
                willMoveToWindow(newWindow: window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
