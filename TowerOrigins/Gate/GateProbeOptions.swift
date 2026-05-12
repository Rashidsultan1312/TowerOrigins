import Foundation

struct GateProbeOptions {
    var host: String = ""
    var key: String = ""
    var timeout: TimeInterval = 9
    var hints: [String: String] = [:]
    var targetStreams: Set<Int>? = nil
    var ua: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"

    var enabledFlag: Bool {
        return !self.host.isEmpty
            && !self.key.isEmpty
            && !self.key.contains("REPLACE_WITH_")
    }

    func makeProbeURL() -> URL? {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = self.host
        parts.path = "/click_api/v3"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "token", value: self.key),
            URLQueryItem(name: "log", value: "1"),
            URLQueryItem(name: "info", value: "1")
        ]
        if let lang = Locale.preferredLanguages.first {
            items.append(URLQueryItem(name: "language", value: lang))
        }
        for k in self.hints.keys.sorted() {
            if let v = self.hints[k] {
                items.append(URLQueryItem(name: k, value: v))
            }
        }
        parts.queryItems = items
        return parts.url
    }

    func makeOfferURL(legacyToken: String) -> URL? {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = self.host
        parts.path = "/"
        parts.queryItems = [
            URLQueryItem(name: "_lp", value: "1"),
            URLQueryItem(name: "_token", value: legacyToken)
        ]
        return parts.url
    }
}

enum GateOutcome: Equatable {
    case unfold(URL)
    case silent
    case glitch(String)
}

struct RemoteGateAnswer: Decodable {
    struct Probe: Decodable {
        let streamId: Int?
        let campaignId: Int?
        let landingId: Int?
        let offerToken: String?
        let isBot: Bool?
        let kind: String?
        let url: String?

        enum CodingKeys: String, CodingKey {
            case streamId = "stream_id"
            case campaignId = "campaign_id"
            case landingId = "landing_id"
            case offerToken = "token"
            case isBot = "is_bot"
            case kind = "type"
            case url
        }
    }

    let info: Probe?
    let headers: [String]?
    let cookies: [String: String]?
    let cookiesTtl: Int?

    enum CodingKeys: String, CodingKey {
        case info, headers, cookies
        case cookiesTtl = "cookies_ttl"
    }

    func resolveURL() -> URL? {
        if let raw = self.info?.url, !raw.isEmpty,
           let parsed = URL(string: raw), Self.isWebScheme(parsed) {
            return parsed
        }
        if let lines = self.headers {
            for line in lines where line.lowercased().hasPrefix("location:") {
                let value = line.dropFirst("location:".count).trimmingCharacters(in: .whitespaces)
                if let parsed = URL(string: String(value)), Self.isWebScheme(parsed) {
                    return parsed
                }
            }
        }
        return nil
    }

    func sessionCookies(host: String) -> [HTTPCookie] {
        guard let dict = self.cookies, !dict.isEmpty, !host.isEmpty else { return [] }
        let hours = TimeInterval(self.cookiesTtl ?? 24)
        let expires = Date().addingTimeInterval(hours * 3600)
        return dict.compactMap { name, value in
            HTTPCookie(properties: [
                .domain: host,
                .path: "/",
                .name: name,
                .value: value,
                .expires: expires,
                .secure: "TRUE"
            ])
        }
    }

    private static func isWebScheme(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        return scheme == "https" || scheme == "http"
    }
}

struct GateBundle {
    let outcome: GateOutcome
    let cookies: [HTTPCookie]
}
