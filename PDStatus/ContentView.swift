import SwiftUI

struct ContentView: View {
    @Binding var incidents: Incidents
    @Binding var updateError: String
    @Binding var updatedAt: Date?
    @State private var hoverId: String = ""
    private let dateFmt = {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .none
        dtfmt.timeStyle = .short
        return dtfmt
    }()

    var body: some View {
        VStack {
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
                List(incidents) { inc in
                    Link(destination: URL(string: inc.htmlUrl)!) {
                        Text(inc.title)
                            .multilineTextAlignment(.leading)
                    }
                    .underline(hoverId == inc.id)
                    .onHover { hovering in
                        hoverId = hovering ? inc.id : ""
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
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                if let upd = updatedAt {
                    Text(dateFmt.string(from: upd))
                } else {
                    Text("-")
                }
            }
            .padding(.bottom, 5)
        }.background(.background)
    }
}

#Preview {
    ContentView(
        incidents: .constant([
            IncidentsResp.Incident(id: "1", title: "!!! INCIDENT 1 !!!", htmlUrl: "http://example.coo/1"),
            IncidentsResp.Incident(id: "2", title: "!!! INCIDENT 2 !!!", htmlUrl: "http://example.coo/2"),
            IncidentsResp.Incident(id: "3", title: "!!! INCIDENT 3 !!!", htmlUrl: "http://example.coo/3"),
        ]),
        updateError: .constant(""),
        updatedAt: .constant(Date())
    )
}
