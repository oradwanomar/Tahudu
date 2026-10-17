import Foundation

public final class AnalyticsEventTrackerMock: AnalyticsEventTracking {
    private let lock = NSLock()
    private var events = [AnalyticsEvent]()

    public init() {}

    public var trackedEvents: [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }

    public func trackEvent(_ event: AnalyticsEvent) {
        lock.lock()
        events.append(event)
        lock.unlock()
    }
}
