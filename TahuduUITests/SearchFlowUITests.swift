import XCTest

final class SearchFlowUITests: XCTestCase {
    func testSearchFavoriteFilterAndPersistence() {
        let app = XCUIApplication()
        app.launchEnvironment["TAHUDU_UI_TEST_STORE"] = UUID().uuidString
        app.launch()

        let marina = app.staticTexts["Marina Heights, Dubai Marina"]
        let palm = app.staticTexts["Palm Residence, Palm Jumeirah"]
        XCTAssertTrue(marina.waitForExistence(timeout: 15))
        XCTAssertTrue(palm.exists)

        let search = app.textFields["search.query"]
        search.tap()
        search.typeText("Marina")
        XCTAssertTrue(marina.exists)
        XCTAssertFalse(palm.exists)

        app.buttons["Done"].tap()
        let favorite = app.buttons["listing.favorite.ui_marina"]
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        favorite.tap()
        XCTAssertTrue(waitForFavorite(favorite))

        app.buttons["Clear search"].tap()
        XCTAssertTrue(palm.waitForExistence(timeout: 5))
        app.buttons["search.favorites.toggle"].tap()
        XCTAssertTrue(app.buttons["Clear favorites filter"].waitForExistence(timeout: 5))
        XCTAssertTrue(marina.exists)
        XCTAssertTrue(waitUntilMissing(palm))

        app.terminate()
        app.launch()
        XCTAssertTrue(marina.waitForExistence(timeout: 15))
        XCTAssertTrue(waitForFavorite(app.buttons["listing.favorite.ui_marina"]))
        app.buttons["search.favorites.toggle"].tap()
        XCTAssertTrue(app.buttons["Clear favorites filter"].waitForExistence(timeout: 5))
        XCTAssertTrue(marina.exists)
        XCTAssertTrue(waitUntilMissing(palm))
    }

    private func waitForFavorite(_ button: XCUIElement) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "Favorite"),
            object: button
        )
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }

    private func waitUntilMissing(_ element: XCUIElement) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }
}
