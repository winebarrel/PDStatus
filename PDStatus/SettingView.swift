//
//  SettingView.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct SettingView: View {
    @AppSecureStorage("apiKey") private var apiKey

    var body: some View {
        Form {
            SecureField("API Key", text: $apiKey)
        }
        .padding(20)
        .frame(width: 300, height: 60)
    }
}

#Preview {
    SettingView()
}
