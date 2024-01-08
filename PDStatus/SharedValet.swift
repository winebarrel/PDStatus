import SwiftUI
import Valet

enum SharedValet {
    static let shared = Valet.valet(with: Identifier(nonEmpty: "winebarrel.PDStatus")!, accessibility: .whenUnlocked)

    static func userID() throws -> String {
        try SharedValet.shared.string(forKey: "userId")
    }

    static func updateUserID(_ newValue: String) {
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
