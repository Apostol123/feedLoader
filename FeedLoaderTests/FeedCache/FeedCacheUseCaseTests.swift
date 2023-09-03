//
//  FeedCacheUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 12/7/23.
//

import XCTest
import FeedLoader

final class FeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recivedMessages, [])
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        sut.save(feed.models) {_ in}

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        sut.save(uniqueImageFeed().models){_ in}
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed])
    }


    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: {timeStamp})
        let feed = uniqueImageFeed()

        sut.save(feed.models){_ in}
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.recivedMessages, [.deletedCachedFeed, .insert(feed.local, timeStamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        expect(sut, toCompleteWithError: deletionError as NSError?) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyError()
        expect(sut, toCompleteWithError: insertionError as NSError?) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }

    func test_save_succeedsOnSuccessfullCacheCreation() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { recivedResults.append($0)})
        sut = nil
        store.completeDeletion(with: anyError())
        XCTAssertTrue(recivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDealocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { recivedResults.append($0)})
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        XCTAssertTrue(recivedResults.isEmpty)
    }



    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for expectation")
        var recivedError: Error?
        sut.save([uniqueImage()]) { result in
            switch result {
            case let .failure(error):
                recivedError = error
            case .success:
                break
            }
            
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(recivedError as NSError?, expectedError, file: file, line: line)
    }
}
