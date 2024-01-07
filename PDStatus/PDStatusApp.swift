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
    @State var incidents: [IncidentsResp.Incident] = []

    private var popover: NSPopover = {
        let po = NSPopover()
        po.behavior = .transient
        po.animates = false
        return po
    }()

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(incidents: $incidents)
        } label: {
            Text("PDStatus")
        }.menuBarExtraAccess(isPresented: self.$isMenuPresented) { statusItem in
            if popover.contentViewController == nil {
                popover.contentViewController = NSHostingController(rootView: ContentView(incidents: $incidents))
            }

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
