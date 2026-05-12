import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var index: JourneyIndex

    var body: some View {
        GateRouterView {
            Group {
                if index.onboardingDone {
                    FacadeTabView()
                } else {
                    OnboardingView()
                }
            }
        } webStage: { url in
            BridgeWebView(url: url)
        }
    }
}
