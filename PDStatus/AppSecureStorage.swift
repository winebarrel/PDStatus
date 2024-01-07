// from https://bsorrentino.github.io/bsorrentino/app/2023/05/29/swiftui-a-property-wrapper-to-secure-settings.html
import SwiftUI
import Valet

enum SharedValet {
    static let shared = Valet.valet(with: Identifier(nonEmpty: "winebarrel.PDStatus")!, accessibility: .whenUnlocked)
}

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {
    private let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: String {
        get {
            (try? SharedValet.shared.string(forKey: key)) ?? ""
        }
        nonmutating set {
            if !newValue.isEmpty {
                try? SharedValet.shared.setString(newValue, forKey: key)
            } else {
                try? SharedValet.shared.removeObject(forKey: key)
            }
        }
    }

    public var projectedValue: Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
