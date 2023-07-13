//
//  FeedCacheUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 12/7/23.
//

import XCTest
import FeedLoader

class LocalFeedLoader {
    private let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0

    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class FeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    // MARK: - Helpers

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), imageURL: URL(string: "www.google.com")!)
    }
}
