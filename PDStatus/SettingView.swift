import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var apiKey: String
    @AppStorage("userId") private var userId = ""
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @AppStorage("interval") private var interval: TimeInterval = 300
    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey).onChange(of: apiKey) {
                SharedValet.apiKey = apiKey
            }
            TextField("Interval (sec)", value: $interval, format: .number.grouping(.never))
                .onChange(of: interval) {
                    if interval < 1 {
                        interval = 1
                    } else if interval > 3600 {
                        interval = 3600
                    }
                }
            TextField("User ID (optional)", text: $userId)
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) {
                    do {
                        if launchAtLogin {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        Log.shared.debug("failed to set 'Launch at login': \(error)")
                    }
                }

            // swiftlint:disable force_cast
            let appVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let buildVer = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            // swiftlint:enable force_cast
            Link("Ver. \(appVer).\(buildVer)", destination: URL(string: "https://github.com/winebarrel/PDStatus")!)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400)
    }

    func onClosed(_ action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            if let window = notification.object as? NSWindow, window.title == "PDStatus Settings" {
                action()
            }
        }
    }
}

#Preview {
    SettingView(
        apiKey: .constant("")
    )
}
