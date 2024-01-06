//
//  PDStatusApp.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import MenuBarExtraAccess
import SwiftUI
import Valet

@main
struct PDStatusApp: App {
    @State var isMenuPresented: Bool = false
    private var popover: NSPopover

    init() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Text("PDStatus")
        }.menuBarExtraAccess(isPresented: self.$isMenuPresented) { statusItem in
            if let button = statusItem.button {
                let mouseHandlerView = MouseHandlerView(frame: button.frame)

                mouseHandlerView.onMouseDown = {
                    if popover.isShown {
                        popover.close()
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
                        popover.contentViewController?.view.window?.makeKey()
                    }
                }

                button.addSubview(mouseHandlerView)
            }
        }
        Settings {
            SettingView()
        }
    }
}
