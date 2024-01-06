//
//  PDStatusApp.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import MenuBarExtraAccess
import SwiftUI

@main
struct PDStatusApp: App {
    @State var isMenuPresented: Bool = false

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Text("PDStatus")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if let button = statusItem.button {
                let mouseHandlerView = MouseHandlerView(frame: button.frame)

                mouseHandlerView.onMouseDown = {
                    print("leftMouseDown")
                }

                button.addSubview(mouseHandlerView)
            }
        }
    }
}
