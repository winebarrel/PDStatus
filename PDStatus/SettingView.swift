import SwiftUI

struct SettingView: View {
    @AppSecureStorage("apiKey") private var apiKey
    @AppStorage("userId") private var userId = ""
    let updateStatus: () -> Void

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey)
            TextField("User ID (optional)", text: $userId)
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
