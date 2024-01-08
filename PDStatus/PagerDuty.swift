import Foundation
import SwiftUI

public struct UsersMeResp: Codable {
    public let user: User

    public struct User: Codable {
        public let id: String
        public let htmlUrl: String
    }
}

public struct OncallsResp: Codable {
    public let oncalls: [Oncall]

    public struct Oncall: Codable {
        public let user: User

        public struct User: Codable {
            public let id: String
        }
    }
}

public struct IncidentsResp: Codable {
    public let incidents: [Incident]

    public struct Incident: Codable, Identifiable {
        public let id: String
        public let title: String
        public let htmlUrl: String
    }
}

typealias Incidents = [IncidentsResp.Incident]

extension Incidents {
    mutating func replaceAll(_ newIncidents: Incidents) {
        replaceSubrange(0 ..< count, with: newIncidents)
    }
}

func - (left: Incidents, right: Incidents) -> Incidents {
    let rightIDs = right.map { $0.id }
    return left.filter { !rightIDs.contains($0.id) }
}

class PagerDuty {
    private let apiEndpoint = URL(string: "https://api.pagerduty.com/")!
    @AppSecureStorage("apiKey") private var apiKey
    @AppStorage("userId") private var userId = ""

    public func update() async throws -> (Bool, Incidents) {
        let userId = try await myUserID()
        let onCallNow = try await onCall(userId: userId)
        let incidents = try await myIncidents(userId: userId)

        return (onCallNow, incidents)
    }

    public func myIncidentsURL() async throws -> URL {
        let user = try await myUser()
        let url = URL(string: user.htmlUrl)!
        let uid = userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? user.id : userId
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/incidents"
        components.query = "assignedToUser=\(uid)"

        return components.url!
    }

    public func myOnCallShiftsURL() async throws -> URL {
        let user = try await myUser()
        let url = URL(string: user.htmlUrl)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/my-on-call/week"

        return components.url!
    }

    public func myUserID() async throws -> String {
        if !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userId
        }

        let user = try await myUser()

        return user.id
    }

    public func myUser() async throws -> UsersMeResp.User {
        let data = try await get(path: "/users/me")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(UsersMeResp.self, from: data)

        return resp.user
    }

    public func onCall(userId: String) async throws -> Bool {
        let data = try await get(path: "/oncalls", queryItems: ["user_ids[]": userId])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(OncallsResp.self, from: data)

        return resp.oncalls.count >= 1
    }

    public func myIncidents(userId: String) async throws -> Incidents {
        let data = try await get(path: "/incidents", queryItems: ["user_ids[]": userId])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let resp = try decoder.decode(IncidentsResp.self, from: data)

        return resp.incidents
    }

    private func get(path: String, queryItems: [String: String] = [:]) async throws -> Data {
        var url = apiEndpoint.appendingPathComponent(path)
        url.append(queryItems: queryItems.map { key, val in URLQueryItem(name: key, value: val) })

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, rawResp) = try await URLSession.shared.data(for: req)

        guard let resp = rawResp as? HTTPURLResponse else {
            fatalError("failed to cast URLResponse to HTTPURLResponse")
        }

        if resp.statusCode != 200 {
            throw PagerDutyError.respNotOK(resp)
        }

        return data
    }
}

enum PagerDutyError: LocalizedError {
    case respNotOK(HTTPURLResponse)

    var errorDescription: String? {
        switch self {
        case let .respNotOK(resp):
            let statusCode = resp.statusCode
            let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            return "PagerDuty API error: \(statusCode) \(statusMessage)"
        }
    }
}
