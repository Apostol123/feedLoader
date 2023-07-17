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
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    private var deletionCompletion = [DeletionCompletion]()

    enum RecivedMessages: Equatable {
        case deletedCachedFeed
        case insert([FeedItem], Date)
    }

    private(set) var recivedMessages = [RecivedMessages]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        recivedMessages.append(.deletedCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }

    func insert(_ items: [FeedItem], timeStamp: Date) {
        recivedMessages.append(.insert(items, timeStamp))
    }
}

final class FeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyError()
        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed])
    }


    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: {timeStamp})
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed, .insert(items, timeStamp)])
    }


    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), imageURL: URL(string: "www.google.com")!)
    }

    private func anyError() -> Error {
        NSError(domain: "any error", code: 1)
    }
}
