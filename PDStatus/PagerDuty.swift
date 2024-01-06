//
//  PagerDuty.swift
//  PDStatus
//
//  Created by 菅原元気 on 2024/01/06.
//

import Foundation

public struct UsersMeResp: Codable {
    public let user: User

    public struct User: Codable {
        public let id: String
    }
}

public struct OncallsResp: Codable {
    public let oncalls: [Oncalls]

    public struct Oncalls: Codable {
        public let user: User

        public struct User: Codable {
            public let id: String
        }
    }
}

class PagerDuty {
    private let apiEndpoint = URL(string: "https://api.pagerduty.com/")!
    @AppSecureStorage("apiKey") private var apiKey

    public func getCurrentUserID() async -> Result<String, Error> {
        let data: Data

        switch await get(path: "/users/me") {
        case .success(let d):
            data = d
        case .failure(let e):
            return .failure(e)
        }

        let decoder = JSONDecoder()
        let resp: UsersMeResp

        do {
            resp = try decoder.decode(UsersMeResp.self, from: data)
        } catch {
            return .failure(error)
        }

        return .success(resp.user.id)
    }

    public func onCall(userId: String) async -> Result<Bool, Error> {
        let data: Data

        switch await get(path: "/oncalls", queryItems: ["user_ids[]": userId]) {
        case .success(let d):
            data = d
        case .failure(let e):
            return .failure(e)
        }

        let decoder = JSONDecoder()
        let resp: OncallsResp

        do {
            resp = try decoder.decode(OncallsResp.self, from: data)
        } catch {
            return .failure(error)
        }

        return .success(resp.oncalls.count >= 1)
    }

    private func get(path: String, queryItems: [String: String] = [:]) async -> Result<Data, Error> {
        var url = apiEndpoint.appendingPathComponent(path)
        url.append(queryItems: queryItems.map { k, v in URLQueryItem(name: k, value: v) })

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")
        let data: Data
        let resp: HTTPURLResponse

        do {
            let (d, r) = try await URLSession.shared.data(for: req)
            data = d
            resp = r as! HTTPURLResponse
        } catch {
            return .failure(error)
        }

        if resp.statusCode != 200 {
            return .failure(PagerDutyError.respNotOK(resp))
        }

        return .success(data)
    }
}

enum PagerDutyError: LocalizedError {
    case respNotOK(HTTPURLResponse)

    var errorDescription: String? {
        switch self {
        case .respNotOK(let resp):
            let statusCode = resp.statusCode
            let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            return "PagerDuty API error: \(statusCode) \(statusMessage)"
        }
    }
}
