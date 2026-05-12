import SwiftUI

@MainActor
final class GateProbe: ObservableObject {
    static let shared = GateProbe()

    @Published var outcome: GateOutcome = .silent
    @Published var resolved: Bool = false
    private(set) var sessionCookies: [HTTPCookie] = []

    private(set) var options = GateProbeOptions()

    private init() {}

    static func bootstrap(host: String,
                          key: String,
                          timeout: TimeInterval = 9,
                          targets: Set<Int>? = nil) {
        var merged = AppConfig.relayHints
        self.shared.options.host = host
        self.shared.options.key = key
        self.shared.options.timeout = timeout
        self.shared.options.targetStreams = targets
        self.shared.options.hints = merged
    }

    func awakeAndProbe() async {
        GateLog.write("Probe start")
        let bundle = await RemoteGateFetcher.probe(self.options)
        self.outcome = bundle.outcome
        self.sessionCookies = bundle.cookies
        self.resolved = true
        GateLog.write("Probe decision \(bundle.outcome) cookies=\(bundle.cookies.count)")
    }

    var unfoldedURL: URL? {
        guard case .unfold(let url) = self.outcome else { return nil }
        return url
    }
}

struct GateRouterView<Facade: View, Web: View>: View {
    @StateObject private var probe = GateProbe.shared
    let facade: () -> Facade
    let webStage: (URL) -> Web

    var body: some View {
        ZStack {
            self.facade()
            if self.probe.resolved, let url = self.probe.unfoldedURL {
                self.webStage(url)
                    .transition(.opacity)
            }
        }
        .task {
            await self.probe.awakeAndProbe()
        }
    }
}
