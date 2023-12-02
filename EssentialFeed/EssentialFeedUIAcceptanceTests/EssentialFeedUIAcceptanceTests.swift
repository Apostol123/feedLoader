//
//  EssentialFeedUIAcceptanceTests.swift
//  EssentialFeedUIAcceptanceTests
//
//  Created by Alex.personal on 29/11/23.
//

import XCTest

final class EssentialFeedUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        XCTAssertEqual(feedCells.firstMatch.images.count, 1)
    }
    
    func test_onLaunch_displaysCacheRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineAPP = XCUIApplication()
        onlineAPP.launchArguments = ["-reset", "-connectivity", "online"]
        onlineAPP.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)
        
        XCTAssertEqual(cachedFeedCells.firstMatch.images.count, 1)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCsutomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
