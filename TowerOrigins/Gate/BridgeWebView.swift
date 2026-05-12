import SwiftUI
@preconcurrency import WebKit

@MainActor
final class BridgeJourney: NSObject, ObservableObject {
    @Published var canRewind: Bool = false
    @Published var canAdvance: Bool = false
    @Published var isFetching: Bool = false
    @Published var fetchProgress: Double = 0

    let pane: WKWebView
    let originURL: URL

    private var watchers: [NSKeyValueObservation] = []
    private var reloadAttempts = 0
    private let reloadCeiling = 4

    init(originURL: URL, ua: String, sessionCookies: [HTTPCookie] = []) {
        self.originURL = originURL

        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        let pane = WKWebView(frame: .zero, configuration: cfg)
        pane.allowsBackForwardNavigationGestures = true
        pane.scrollView.bounces = true
        pane.isOpaque = false
        pane.backgroundColor = .clear
        pane.scrollView.backgroundColor = .clear
        pane.customUserAgent = ua
        self.pane = pane

        super.init()

        pane.navigationDelegate = self
        self.watchers = [
            pane.observe(\.canGoBack, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canRewind = wv.canGoBack }
            },
            pane.observe(\.canGoForward, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canAdvance = wv.canGoForward }
            },
            pane.observe(\.isLoading, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.isFetching = wv.isLoading }
            },
            pane.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.fetchProgress = wv.estimatedProgress }
            }
        ]

        GateLog.write("Bridge init target=\(originURL.absoluteString) cookies=\(sessionCookies.count)")
        if sessionCookies.isEmpty {
            self.pane.load(URLRequest(url: originURL))
        } else {
            let store = pane.configuration.websiteDataStore.httpCookieStore
            Task { @MainActor [weak self] in
                for cookie in sessionCookies {
                    GateLog.write("Bridge set cookie \(cookie.name) domain=\(cookie.domain)")
                    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                        store.setCookie(cookie) { cont.resume() }
                    }
                }
                GateLog.write("Bridge cookies set, loading")
                self?.pane.load(URLRequest(url: originURL))
            }
        }
    }

    deinit {
        self.watchers.forEach { $0.invalidate() }
    }

    func rewind() { self.pane.goBack() }
    func advance() { self.pane.goForward() }
    func restart() { self.pane.reload() }
    func revisitOrigin() { self.pane.load(URLRequest(url: self.originURL)) }

    nonisolated static func isRetryable(_ err: NSError) -> Bool {
        guard err.domain == NSURLErrorDomain else { return false }
        switch err.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorDataNotAllowed:
            return true
        default:
            return false
        }
    }

    private func scheduleReload(reason: String) async {
        guard self.reloadAttempts < self.reloadCeiling else {
            GateLog.write("Bridge reload limit \(self.reloadAttempts)/\(self.reloadCeiling)")
            return
        }
        self.reloadAttempts += 1
        let waitSec = min(8, 1 << (self.reloadAttempts - 1))
        GateLog.write("Bridge reload #\(self.reloadAttempts) in \(waitSec)s — \(reason)")
        try? await Task.sleep(nanoseconds: UInt64(waitSec) * 1_000_000_000)
        if self.pane.url == nil {
            self.pane.load(URLRequest(url: self.originURL))
        } else {
            self.pane.reload()
        }
    }
}

extension BridgeJourney: WKNavigationDelegate {
    func webView(_ wv: WKWebView,
                 decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let target = action.request.url else { return .cancel }
        switch target.scheme ?? "" {
        case "tel", "mailto", "itms-apps", "itms-appss":
            await UIApplication.shared.open(target)
            return .cancel
        default:
            return .allow
        }
    }

    nonisolated func webView(_ wv: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        GateLog.write("Bridge start nav → \(wv.url?.absoluteString ?? "nil")")
    }

    nonisolated func webView(_ wv: WKWebView, didFinish navigation: WKNavigation!) {
        GateLog.write("Bridge finish nav → \(wv.url?.absoluteString ?? "nil")")
        Task { @MainActor [weak self] in self?.reloadAttempts = 0 }
    }

    nonisolated func webView(_ wv: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        GateLog.write("Bridge didFail \(nsErr.domain) \(nsErr.code)")
        guard !(nsErr.domain == NSURLErrorDomain && nsErr.code == NSURLErrorCancelled) else { return }
        guard Self.isRetryable(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleReload(reason: "didFail \(nsErr.code)")
        }
    }

    nonisolated func webView(_ wv: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        GateLog.write("Bridge provisional \(nsErr.domain) \(nsErr.code)")
        guard !(nsErr.domain == NSURLErrorDomain && nsErr.code == NSURLErrorCancelled) else { return }
        guard Self.isRetryable(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleReload(reason: "provisional \(nsErr.code)")
        }
    }
}

private struct BridgeCanvas: UIViewRepresentable {
    let pane: WKWebView
    func makeUIView(context: Context) -> WKWebView { return self.pane }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct BridgeWebView: View {
    @StateObject private var journey: BridgeJourney

    init(url: URL) {
        _journey = StateObject(wrappedValue: BridgeJourney(
            originURL: url,
            ua: GateProbe.shared.options.ua,
            sessionCookies: GateProbe.shared.sessionCookies
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                BridgeCanvas(pane: self.journey.pane)
                    .ignoresSafeArea(edges: [.top, .horizontal])

                if self.journey.isFetching {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Pigment.gold)
                            .frame(width: geo.size.width * self.journey.fetchProgress, height: 2)
                            .animation(.easeInOut(duration: 0.2), value: self.journey.fetchProgress)
                    }
                    .frame(height: 2)
                    .ignoresSafeArea(edges: [.top, .horizontal])
                }
            }

            BridgeHelm(journey: self.journey)
        }
        .background(Pigment.navy.ignoresSafeArea())
    }
}

private struct BridgeHelm: View {
    @ObservedObject var journey: BridgeJourney

    var body: some View {
        HStack(spacing: 0) {
            self.helmButton(symbol: "chevron.left",
                            enabled: self.journey.canRewind) { self.journey.rewind() }
            self.helmButton(symbol: "chevron.right",
                            enabled: self.journey.canAdvance) { self.journey.advance() }
            self.helmButton(symbol: "house.fill",
                            enabled: true,
                            weight: .semibold) { self.journey.revisitOrigin() }
            self.helmButton(symbol: "arrow.clockwise",
                            enabled: true) { self.journey.restart() }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            Pigment.surface.ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Pigment.gold.opacity(0.18))
                .frame(height: 0.5),
            alignment: .top
        )
    }

    @ViewBuilder
    private func helmButton(symbol: String,
                            enabled: Bool,
                            weight: Font.Weight = .regular,
                            action: @escaping () -> Void) -> some View {
        Button {
            guard enabled else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: weight))
                .foregroundStyle(enabled
                                 ? Pigment.textHi.opacity(0.92)
                                 : Pigment.textLow.opacity(0.45))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}
