//
//  ValidateFeedCacheUseCaseTest.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 10/8/23.
//

import XCTest
import FeedLoader

final class ValidateFeedCacheUseCaseTest: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeRetrieval(with: anyError())

        XCTAssertEqual(store.recivedMessages, [.retrive, .deletedCachedFeed])
    }

    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimeStamp)
        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    func test_validateCache_DeletesExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredCacheTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: expiredCacheTimeStamp)
        XCTAssertEqual(store.recivedMessages, [.retrive, .deletedCachedFeed])
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyError())

        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

