//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 23/7/23.
//

import XCTest
import FeedLoader

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load {_ in}
        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }

    func test_load_deliversCacheImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        expect(sut, toCompleteWith: .success(feed.models), when:  {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        })
    }

    func test_load_deliversNoImagesOnThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        expect(sut, toCompleteWith: .success([]), when:  {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        expect(sut, toCompleteWith: .success([]), when:  {
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        })
    }

    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.recivedMessages, [.retrive, .deletedCachedFeed])
    }

    func test_load_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.recivedMessages, [.retrive])
    }

    // MARK: - Helpers
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let localFeedItems = models.map({LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
        return (models, localFeedItems)
    }

    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: URL(string: "www.google.com")!)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedImages), .success(expectedImages)):
                XCTAssertEqual(recievedImages, expectedImages, file: file, line: line)

            case let (.failure(recievedError), .failure(expectedError)):
                XCTAssertEqual(recievedError as NSError, expectedError as NSError, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult) got \(recievedResult) instead")

            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func anyError() -> Error {
        NSError(domain: "any error", code: 1)
    }
}


private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
