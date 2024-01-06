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
                let userId: String

                switch await pd.getCurrentUserID() {
                case .success(let id):
                    userId = id
                case .failure(let e):
                    print(e)
                    return
                }

                switch await pd.onCall(userId: userId) {
                case .success(let oc):
                    print(oc)
                case .failure(let e):
                    print(e)
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
