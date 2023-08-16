//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 15/8/23.
//

import XCTest
import FeedLoader

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "imagefeed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timeStamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "imagefeed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "imagefeed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrive_deliversOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for expectation")
        
        sut.retrieve(completion: { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for expectation")
        sut.retrieve(completion: { firstResult in
            sut.retrieve(completion: { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result, got \([firstResult, secondResult]) instead")
                }
                
                exp.fulfill()
            })
        })
        
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retriveAfterInsetingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "wait for expectation")
        sut.insert(feed, timeStamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve(completion: { retriveResult in
                switch retriveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                   XCTAssertEqual(retrievedFeed, feed)
                   XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Expected a found result with feed \(feed) and timeStamp \(timestamp), got \(retriveResult) instead")
                }
                
                exp.fulfill()
            })

        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
