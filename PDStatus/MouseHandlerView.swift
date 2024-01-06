//
//  MouseHandlerView.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

// from https://github.com/orchetect/MenuBarExtraAccess/discussions/2#discussioncomment-5744323
class MouseHandlerView: NSView {
    var onRightMouseDown: (() -> Void)? = nil
    var onMouseDown: (() -> Void)? = nil

    override func rightMouseDown(with event: NSEvent) {
        if let onRightMouseDown {
            onRightMouseDown()
        } else {
            super.rightMouseDown(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let onMouseDown {
            onMouseDown()
        } else {
            super.mouseDown(with: event)
        }
    }
}
