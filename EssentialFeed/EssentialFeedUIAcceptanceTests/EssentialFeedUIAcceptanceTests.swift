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
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        XCTAssertEqual(feedCells.firstMatch.images.count, 1)
    }
    
    
}
