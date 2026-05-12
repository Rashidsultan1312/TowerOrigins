import Foundation

enum RemoteGateFetcher {
    private static let session: URLSession = {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.waitsForConnectivity = false
        cfg.urlCache = nil
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: cfg)
    }()

    private static let attempts = 3
    private static let pauses: [UInt64] = [800_000_000, 2_000_000_000]

    private enum Step {
        case ok(Data)
        case retry(String)
        case stop(String)
    }

    static func probe(_ opts: GateProbeOptions) async -> GateBundle {
        let idle = GateBundle(outcome: .silent, cookies: [])
        GateLog.write("probe ready=\(opts.enabledFlag) host=\(opts.host)")
        guard opts.enabledFlag else { return idle }
        guard let url = opts.makeProbeURL() else { return idle }
        GateLog.write("GET \(url.absoluteString)")

        var req = URLRequest(url: url, timeoutInterval: opts.timeout)
        req.setValue(opts.ua, forHTTPHeaderField: "User-Agent")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let lang = Locale.preferredLanguages.first {
            req.setValue(lang, forHTTPHeaderField: "Accept-Language")
        }

        for attempt in 1...self.attempts {
            switch await self.singleShot(req, attempt: attempt) {
            case .ok(let data):
                return self.decide(data, opts: opts)
            case .stop(let reason):
                GateLog.write("terminal: \(reason)")
                if reason.hasPrefix("auth") {
                    return GateBundle(outcome: .glitch("invalid_token"), cookies: [])
                }
                if reason.hasPrefix("disabled") {
                    return GateBundle(outcome: .glitch("click_api_disabled"), cookies: [])
                }
                return idle
            case .retry(let reason):
                GateLog.write("transient: \(reason) #\(attempt)/\(self.attempts)")
                if attempt < self.attempts {
                    let nanos = self.pauses[min(attempt - 1, self.pauses.count - 1)]
                    try? await Task.sleep(nanoseconds: nanos)
                    continue
                }
                GateLog.write("retries exhausted")
                return idle
            }
        }
        return idle
    }

    private static func singleShot(_ req: URLRequest, attempt: Int) async -> Step {
        do {
            let (data, response) = try await self.session.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                return .retry("no-http")
            }
            GateLog.write("HTTP \(http.statusCode) #\(attempt)")
            switch http.statusCode {
            case 200...299:
                return .ok(data)
            case 401, 403:
                return .stop("auth \(http.statusCode)")
            case 409:
                return .stop("disabled \(http.statusCode)")
            case 404, 410:
                return .stop("not-found \(http.statusCode)")
            case 408, 425, 429, 500, 502, 503, 504:
                return .retry("retryable \(http.statusCode)")
            case 400...499:
                return .stop("client \(http.statusCode)")
            default:
                return .retry("status \(http.statusCode)")
            }
        } catch {
            let nsErr = error as NSError
            if nsErr.domain == NSURLErrorDomain {
                switch nsErr.code {
                case NSURLErrorCancelled, NSURLErrorBadURL, NSURLErrorUnsupportedURL,
                     NSURLErrorAppTransportSecurityRequiresSecureConnection:
                    return .stop("nsurl \(nsErr.code)")
                default:
                    return .retry("nsurl \(nsErr.code)")
                }
            }
            return .retry("error")
        }
    }

    private static func decide(_ data: Data, opts: GateProbeOptions) -> GateBundle {
        guard let answer = try? JSONDecoder().decode(RemoteGateAnswer.self, from: data) else {
            GateLog.write("decode failed")
            return GateBundle(outcome: .silent, cookies: [])
        }
        let jar = answer.sessionCookies(host: opts.host)
        GateLog.write("decoded streamId=\(answer.info?.streamId.map(String.init) ?? "nil") tokenPresent=\(answer.info?.offerToken?.isEmpty == false) cookies=\(jar.count)")

        if let bot = answer.info?.isBot, bot {
            return GateBundle(outcome: .silent, cookies: jar)
        }
        if let allowed = opts.targetStreams,
           let sid = answer.info?.streamId,
           !allowed.contains(sid) {
            return GateBundle(outcome: .silent, cookies: jar)
        }
        if let resolved = answer.resolveURL() {
            return GateBundle(outcome: .unfold(resolved), cookies: jar)
        }
        if let token = answer.info?.offerToken,
           !token.isEmpty,
           let built = opts.makeOfferURL(legacyToken: token) {
            return GateBundle(outcome: .unfold(built), cookies: jar)
        }
        return GateBundle(outcome: .silent, cookies: jar)
    }
}

enum GateLog {
    static func write(_ message: String) {
        #if DEBUG
        print("[Gate] \(message)")
        #endif
    }
}
