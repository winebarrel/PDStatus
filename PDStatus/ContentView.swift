//
//  ContentView.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
