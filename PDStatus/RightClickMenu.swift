//
//  RightClickMenu.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct RightClickMenu: View {
    var body: some View {
        Button("Update Manually") {
            let pd = PagerDuty()

            Task {
                do {
                    let (onCallNow, incidents) = try await pd.update()
                    print(onCallNow)
                    print(incidents)
                } catch {
                    print(error)
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
