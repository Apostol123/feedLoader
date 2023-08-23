//
//  XCTest+FeedStoreSpecs.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 23/8/23.
//

import FeedLoader
import XCTest

extension FeedStoreSpecs where Self: XCTestCase{
    @discardableResult
    func insert (_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timestamp) { recivedInsertionError in
            insertionError = recivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}
