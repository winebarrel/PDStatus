import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var apiKey: String
    @AppStorage("userId") private var userId = ""
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    let updateStatus: (Bool) -> Void

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey).onChange(of: apiKey) {
                SharedValet.updateUserID(apiKey)
            }
            TextField("User ID (optional)", text: $userId)
#if swift(>=5.9)
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
        .onSubmit {
            updateStatus(false)
        }
    }
}

#if swift(>=5.9)
#Preview {
    SettingView(
        apiKey: .constant(""),
        updateStatus: { _ in }
    )
}
#endif
