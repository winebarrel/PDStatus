import os

enum Log {
    static let shared = Logger(subsystem: "winebarrel.PDStatus", category: "Application")
}
