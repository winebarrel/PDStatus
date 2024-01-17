import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var apiKey: String
    @AppStorage("userId") private var userId = ""
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @Binding var interval: TimeInterval
    var body: some View {
        Form {
#if swift(>=5.9)
            SecureField("API Key", text: $apiKey).onChange(of: apiKey) {
                SharedValet.updateUserID(apiKey)
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
#else
            #warning("requires swift 5.9 or higher")
#endif
        }
        .padding(20)
        .frame(width: 400)
    }
}

#if swift(>=5.9)
#Preview {
    SettingView(
        apiKey: .constant(""),
        interval: .constant(300)
    )
}
#endif
