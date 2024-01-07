//
//  RightClickMenu.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct RightClickMenu: View {
    var body: some View {
        // TODO: debug
        Button("Test") {
            let pd = PagerDuty()

            Task {
                let userId: String

                switch await pd.myUserID() {
                case .success(let id):
                    userId = id
                case .failure(let e):
                    print(e)
                    return
                }

                switch await pd.onCall(userId: userId) {
                case .success(let onCall):
                    print(onCall)
                case .failure(let e):
                    print(e)
                }

                switch await pd.myIncidents(userId: userId) {
                case .success(let incidents):
                    print(incidents)
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
