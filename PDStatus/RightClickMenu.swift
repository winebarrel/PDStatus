//
//  RightClickMenu.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct RightClickMenu: View {
    func actin() {}

    var body: some View {
        SettingsLink {
            Text("Settings")
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(self)
        }
    }
}

#Preview {
    RightClickMenu()
}
