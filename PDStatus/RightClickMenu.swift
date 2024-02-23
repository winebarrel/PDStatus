import SwiftUI

struct RightClickMenu: View {
    @Binding var apiKey: String
    let updateStatus: (Bool) -> Void

    var body: some View {
        Button("My Incidents") {
            let pdcli = PagerDuty(apiKey: apiKey)

            Task {
                do {
                    let url = try await pdcli.myIncidentsURL()
                    NSWorkspace.shared.open(url)
                } catch {
                    Log.shared.debug("failed to open 'My Incidents': \(error)")
                }
            }
        }
        Button("My On-Call Shifts") {
            let pdcli = PagerDuty(apiKey: apiKey)

            Task {
                do {
                    let url = try await pdcli.myOnCallShiftsURL()
                    NSWorkspace.shared.open(url)
                } catch {
                    Log.shared.debug("failed to open 'My On-Call Shifts': \(error)")
                }
            }
        }
        Divider()
        Button("Update Manually") {
            updateStatus(true)
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
    RightClickMenu(
        apiKey: .constant(""),
        updateStatus: { _ in }
    )
}
