import SwiftUI

struct RightClickMenu: View {
    let updateStatus: () -> Void

    var body: some View {
        Button("My On-Call Shifts") {
            let pdcli = PagerDuty()

            Task {
                do {
                    let url = try await pdcli.myOnCallShiftsURL()
                    NSWorkspace.shared.open(url)
                } catch {
                    Log.shared.debug("failed to open 'My On-Call Shifts': \(error)")
                }
            }
        }
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
