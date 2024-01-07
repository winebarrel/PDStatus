import SwiftUI

struct ContentView: View {
    @Binding var incidents: Incidents
    @Binding var updateError: String
    @State var hoverId: String = ""

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
                    Text(i.title)
                        .multilineTextAlignment(.leading)
                }
                .underline(hoverId == i.id)
                .onHover { hovering in
                    hoverId = hovering ? i.id : ""
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
