@testable import Analytics
import AnalyticsInterface
import Testing

@Test func trackerForwardsEventsToItsDestination() {
    var receivedEvent: AnalyticsEvent?
    let tracker = AnalyticsEventTracker { receivedEvent = $0 }
    let event = AnalyticsEvent(name: "tab_viewed", parameters: ["tab": "search"])

    tracker.trackEvent(event)

    #expect(receivedEvent?.name == "tab_viewed")
    #expect(receivedEvent?.parameters?["tab"] as? String == "search")
}

@Test func mockRecordsEvents() {
    let tracker = AnalyticsEventTrackerMock()
    tracker.trackEvent(AnalyticsEvent(name: "app_opened"))

    #expect(tracker.trackedEvents.map(\.name) == ["app_opened"])
}
