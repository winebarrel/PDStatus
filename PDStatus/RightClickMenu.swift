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

#if swift(>=5.9)
#Preview {
    RightClickMenu(updateStatus: {})
}
#endif
