//
//  PDStatusApp.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import MenuBarExtraAccess
import SwiftUI
import Valet

enum StatusIcon: String {
    case notOnCallWithoutIncident = "bell.slash"
    case notOnCallWithIncident = "bell.badge.slash"
    case onCallWithoutIncident = "bell.fill"
    case onCallWithIncident = "bell.and.waves.left.and.right.fill"
    case error = "exclamationmark.triangle"
}

typealias Incidents = [IncidentsResp.Incident]

extension Incidents {
    mutating func replaceAll(_ newIncidents: Incidents) {
        replaceSubrange(0 ..< count, with: newIncidents)
    }
}

@main
struct PDStatusApp: App {
    @State var isMenuPresented: Bool = false
    @State var incidents: Incidents = []
    @State var onCallStatus = StatusIcon.notOnCallWithoutIncident
    @State var updateError = ""

    private var popover: NSPopover = {
        let po = NSPopover()
        po.behavior = .transient
        po.animates = false
        return po
    }()

    func updateStatus() {
        let pd = PagerDuty()

        Task {
            do {
                let (onCallNow, incs) = try await pd.update()
                updateError = ""
                incidents.replaceAll(incs)

                if onCallNow {
                    onCallStatus = incs.count == 0 ? .onCallWithoutIncident : .onCallWithIncident
                } else {
                    onCallStatus = incs.count == 0 ? .notOnCallWithoutIncident : .notOnCallWithIncident
                }
            } catch {
                onCallStatus = .error
                updateError = error.localizedDescription
            }
        }
    }

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(updateStatus: updateStatus)
        } label: {
            Image(systemName: onCallStatus.rawValue)
            Text("PDStatus")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if popover.contentViewController == nil {
                popover.contentViewController = NSHostingController(rootView: ContentView(incidents: $incidents, updateError: $updateError))
            }

            if let button = statusItem.button {
                let mouseHandlerView = MouseHandlerView(frame: button.frame)

                mouseHandlerView.onMouseDown = {
                    if popover.isShown {
                        popover.performClose(nil)
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
                        popover.contentViewController?.view.window?.makeKey()
                    }
                }

                button.addSubview(mouseHandlerView)

                Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                    updateStatus()
                }.fire()
            }
        }
        Settings {
            SettingView()
        }
    }
}
