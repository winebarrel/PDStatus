//
//  SettingView.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct SettingView: View {
    @AppSecureStorage("apiKey") private var apiKey
    @AppStorage("userId") private var userId = ""
    @AppStorage("interval") private var interval = 60

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey)
            TextField("Update Interval", value: $interval, format: .number).onSubmit {
                if interval < 10 {
                    interval = 10
                }
            }
            TextField("User ID (optional)", text: $userId)
        }
        .padding(20)
        .frame(width: 400)
    }
}

#Preview {
    SettingView()
}
