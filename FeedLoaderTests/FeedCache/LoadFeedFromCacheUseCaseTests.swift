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
        let exp = expectation(description: "Wait for load completion")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure got \(result) instead")
            }

            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError as NSError)
    }

//    func test_load_deliversNoImagesOnEmptyCache() {
//        let (sut, store) = makeSUT()
//        let exp = expectation(description: "Wait for load completion")
//        var receivedImages: [FeedImage]
//        sut.load { result in
//            receivedImages = error
//            exp.fulfill()
//        }
//
//        store.completeRetrieval(with: retrievalError)
//        wait(for: [exp], timeout: 1.0)
//        XCTAssertEqual(receivedError as NSError?, retrievalError as NSError)
//    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyError() -> Error {
        NSError(domain: "any error", code: 1)
    }
}