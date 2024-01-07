import SwiftUI

struct RightClickMenu: View {
    let updateStatus: () -> Void

    var body: some View {
        Button("Update Manually") {
            updateStatus()
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
    RightClickMenu(updateStatus: {})
}
