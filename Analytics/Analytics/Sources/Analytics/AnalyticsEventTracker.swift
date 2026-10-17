import AnalyticsInterface
import Foundation
import OSLog

public final class AnalyticsEventTracker: AnalyticsEventTracking {
    private let send: (AnalyticsEvent) -> Void

    public init() {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Tahudu", category: "Analytics")
        send = { event in
            let parameters = String(describing: event.parameters ?? [:])
            logger.info("Event: \(event.name, privacy: .public), parameters: \(parameters, privacy: .private)")
        }
    }

    public init(send: @escaping (AnalyticsEvent) -> Void) {
        self.send = send
    }

    public func trackEvent(_ event: AnalyticsEvent) {
        send(event)
    }
}
