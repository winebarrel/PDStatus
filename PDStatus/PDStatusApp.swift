import MenuBarExtraAccess
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
    @State var apiKey = ""
    @State var updatedAt: Date?
    @State var timer: Timer?
    @State var interval: TimeInterval = 300

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        return pop
    }()

    func updateStatus(_ showError: Bool) {
        let pdcli = PagerDuty(apiKey: apiKey)

        Task {
            do {
                let (onCallNow, incs) = try await pdcli.update()
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

                        for inc in newIncs {
                            let content = UNMutableNotificationContent()
                            content.title = inc.title
                            content.userInfo = ["url": inc.htmlUrl]
                            content.sound = UNNotificationSound.default
                            let req = UNNotificationRequest(identifier: "winebarrel.PDStatus.\(inc.id)", content: content, trigger: nil)
                            try? await userNotificationCenter.add(req)
                        }
                    }
                }

                updatedAt = Date()
            } catch {
                if showError {
                    onCallStatus = .error
                    updateError = error.localizedDescription
                } else {
                    Log.shared.debug("failed to update PagerDuty status: \(error)")
                }
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            updateStatus(false)
        }
        timer?.fire()
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(
                apiKey: $apiKey,
                updateStatus: updateStatus
            )
        } label: {
            Image(systemName: onCallStatus.rawValue)
            Text("PD").foregroundStyle(Color.blue)
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            apiKey = SharedValet.apiKey
            let userNotificationCenter = UNUserNotificationCenter.current()

            userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { authorized, _ in
                guard authorized else {
                    Log.shared.debug("user notificationCentern not authorized")
                    return
                }
            }

            if popover.contentViewController == nil {
                let view = ContentView(incidents: $incidents, updateError: $updateError, updatedAt: $updatedAt)
                popover.contentViewController = NSHostingController(rootView: view)
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
                startTimer()
            }
        }
        Settings {
            SettingView(
                apiKey: $apiKey,
                interval: $interval
            ).onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
                if let window = notification.object as? NSWindow, window.title == "PDStatus Settings" {
                    startTimer()
                }
            }
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

        guard let url = userInfo["url"] as? String else {
            fatalError("failed to cast userInfo['url'] to String")
        }

        NSWorkspace.shared.open(URL(string: url)!)
        completionHandler()
    }
}
