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
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeedLoad: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        internal init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeedLoad, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timeStamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let storeURL = testSpecificStoreURL()
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        let storeURL = testSpecificStoreURL()
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrive_deliversOnEmptyCache() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    //MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let storeURL = testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
}
