import ServiceManagement
import SwiftUI

struct SettingView: View {
    @AppSecureStorage("apiKey") private var apiKey
    @AppStorage("userId") private var userId = ""
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    let updateStatus: () -> Void

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey)
            TextField("User ID (optional)", text: $userId)
            Toggle("Launch at login", isOn: $launchAtLogin)
            #if swift(>=5.9)
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
            #endif
        }
        .padding(20)
        .frame(width: 400)
        .onSubmit {
            updateStatus()
        }
    }
}

#if swift(>=5.9)
    #Preview {
        SettingView(updateStatus: {})
    }
#endif
