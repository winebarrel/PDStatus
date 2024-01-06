//
//  AppSecureStorage.swift
//  from https://bsorrentino.github.io/bsorrentino/app/2023/05/29/swiftui-a-property-wrapper-to-secure-settings.html
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import SwiftUI
import Valet

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {
    private static let valet = Valet.valet(with: Identifier(nonEmpty: "winebarrel.PDStatus")!, accessibility: .whenUnlocked)
    private let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: String {
        get {
            (try? AppSecureStorage.valet.string(forKey: key)) ?? ""
        }
        nonmutating set {
            if !newValue.isEmpty {
                try? AppSecureStorage.valet.setString(newValue, forKey: key)
            } else {
                try? AppSecureStorage.valet.removeObject(forKey: key)
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
