//
//  PDStatusApp.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import MenuBarExtraAccess
import os
import SwiftUI
import UserNotifications
import Valet

enum StatusIcon: String {
    case notOnCallWithoutIncident = "bell.slash"
    case notOnCallWithIncident = "bell.badge.slash"
    case onCallWithoutIncident = "bell.fill"
    case onCallWithIncident = "bell.and.waves.left.and.right.fill"
    case error = "exclamationmark.triangle"
}

@main
struct PDStatusApp: App {
    @State var isMenuPresented: Bool = false
    @State var incidents: Incidents = []
    @State var onCallStatus = StatusIcon.notOnCallWithoutIncident
    @State var updateError = ""
    private let logger = Logger(subsystem: "winebarrel.PDStatus", category: "Application")

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
                let newIncs = incs - incidents
                incidents.replaceAll(incs)

                if onCallNow {
                    onCallStatus = incs.count == 0 ? .onCallWithoutIncident : .onCallWithIncident
                } else {
                    onCallStatus = incs.count == 0 ? .notOnCallWithoutIncident : .notOnCallWithIncident
                }

                if newIncs.count > 0 {
                    Task {
                        let userNotificationCenter = UNUserNotificationCenter.current()

                        for i in newIncs {
                            let content = UNMutableNotificationContent()
                            content.title = i.title
                            content.userInfo = ["url": i.htmlUrl]
                            content.sound = UNNotificationSound.default
                            let req = UNNotificationRequest(identifier: "winebarrel.PDStatus.\(i.id)", content: content, trigger: nil)
                            try? await userNotificationCenter.add(req)
                        }
                    }
                }
            } catch {
                onCallStatus = .error
                updateError = error.localizedDescription
            }
        }
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let url = URL(string: userInfo["url"] as! String)!
        NSWorkspace.shared.open(url)
        completionHandler()
    }
}
