//
//  FeedEndpointTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 22/1/24.
//

import XCTest
import FeedLoader

final class FeedEndpointTests: XCTestCase {

    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get.url(baseURL: baseURL)

        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v1/feed", "past")
        XCTAssertEqual(received.query(percentEncoded: false), "limit=10", "query")
    }

}
