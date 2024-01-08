import SwiftUI

struct RightClickMenu: View {
    let updateStatus: () -> Void

    var body: some View {
        Button("Update Manually") {
            updateStatus()
        }
        #if swift(>=5.9)
        SettingsLink {
            Text("Settings")
        }
        #endif
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
