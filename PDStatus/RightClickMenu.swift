//
//  RightClickMenu.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct RightClickMenu: View {
    @Binding var incidents: [IncidentsResp.Incident]

    var body: some View {
        Button("Update Manually") {
            let pd = PagerDuty()

            Task {
                do {
                    let (onCallNow, incs) = try await pd.update()
                    print(onCallNow)
                    incidents.replaceSubrange(0 ..< incidents.count, with: incs)
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
    RightClickMenu(incidents: .constant([]))
}
