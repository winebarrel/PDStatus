// from https://bsorrentino.github.io/bsorrentino/app/2023/05/29/swiftui-a-property-wrapper-to-secure-settings.html
import SwiftUI
import Valet

enum SharedValet {
    static let shared = Valet.valet(with: Identifier(nonEmpty: "winebarrel.PDStatus")!, accessibility: .whenUnlocked)

    static func userID() throws -> String {
        try SharedValet.shared.string(forKey: "userId")
    }

    static func updateUserID(_ newValue: String) {
        print("newValue: \(newValue)")
        do {
            if !newValue.isEmpty {
                try SharedValet.shared.setString(newValue, forKey: "userId")
            } else {
                try SharedValet.shared.removeObject(forKey: "userId")
            }
        } catch {
            Log.shared.debug("failed to set UserID to Valet: \(error)")
        }
    }
}
