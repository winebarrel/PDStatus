//
//  ContentView.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI

struct ContentView: View {
    @Binding var incidents: Incidents
    @Binding var updateError: String

    var body: some View {
        if !updateError.isEmpty {
            List {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .imageScale(.large)
                    Text(updateError)
                    Spacer()
                }
            }
        } else if incidents.count > 0 {
            List(incidents) { i in
                Link(destination: URL(string: i.htmlUrl)!) {
                    Text(i.title).multilineTextAlignment(.leading)
                }
            }
        } else {
            List {
                HStack {
                    Spacer()
                    Image(systemName: "face.smiling")
                        .imageScale(.large)
                    Text("There are no incidents")
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView(
        incidents: .constant([
            IncidentsResp.Incident(id: "1", title: "!!! INCIDENT 1 !!!", htmlUrl: "http://example.coo/1"),
            IncidentsResp.Incident(id: "2", title: "!!! INCIDENT 2 !!!", htmlUrl: "http://example.coo/2"),
            IncidentsResp.Incident(id: "3", title: "!!! INCIDENT 3 !!!", htmlUrl: "http://example.coo/3"),
        ]),
        updateError: .constant("")
    )
}
