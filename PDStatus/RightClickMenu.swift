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
        // TODO: debug
        Button("Test") {
            let pd = PagerDuty()

            Task {
                switch await pd.getCurrentUserID() {
                case .success(let userId):
                    print(userId)
                case .failure(let e):
                    print(e.localizedDescription)
                }
            }
        }
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
