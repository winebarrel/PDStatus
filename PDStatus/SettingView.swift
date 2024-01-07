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

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey)
            TextField("User ID (optional)", text: $userId)
        }
        .padding(20)
        .frame(width: 400)
    }
}

#Preview {
    SettingView()
}
