import SwiftUI
import Valet

enum SharedValet {
    static let shared = Valet.valet(with: Identifier(nonEmpty: "winebarrel.PDStatus")!, accessibility: .whenUnlocked)

    static var apiKey: String {
        get {
            do {
                // XXX: Use the key "userId" for compatibility
                return try shared.string(forKey: "userId")
            } catch KeychainError.itemNotFound {
                // nothing to do
            } catch {
                Log.shared.error("failed to get apiKey from Valet: \(error)")
            }

            return ""
        }

        set(apiKey) {
            do {
                if apiKey.isEmpty {
                    // XXX: Use the key "userId" for compatibility
                    try shared.removeObject(forKey: "userId")
                } else {
                    // XXX: Use the key "userId" for compatibility
                    try shared.setString(apiKey, forKey: "userId")
                }
            } catch {
                Log.shared.error("failed to set apiKey to Valet: \(error)")
            }
        }
    }
}
