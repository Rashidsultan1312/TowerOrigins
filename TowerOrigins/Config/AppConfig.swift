import Foundation
import UIKit

enum AppConfig {
    static let relayHost = "tracker.tower-origins.app"
    static let relayKey = "REPLACE_WITH_CAMPAIGN_TOKEN"
    static let relayTimeout: TimeInterval = 9
    static let relayTargets: Set<Int>? = nil

    static let privacyPolicyURL = "https://hallowtommy.github.io/towerorigins-privacy"
    static let supportEmail = "support@towerorigins.app"

    static var marketingVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    static var relayHints: [String: String] {
        var bag: [String: String] = [:]
        bag["sub_id_1"] = Bundle.main.bundleIdentifier ?? "unknown"
        bag["sub_id_2"] = "\(self.marketingVersion)-\(self.buildNumber)"
        bag["sub_id_3"] = Locale.preferredLanguages.first ?? "en"
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            bag["sub_id_4"] = idfv
        }
        bag["sub_id_5"] = "ios"
        return bag
    }
}
