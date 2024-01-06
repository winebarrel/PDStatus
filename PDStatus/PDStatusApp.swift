//
//  PDStatusApp.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

@main
struct PDStatusApp: App {
    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Text("PDStatus")
        }
    }
}
