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
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeedLoad, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timeStamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrive_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert((feed: feed, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_retrivehasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert((feed: feed, timestamp: timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalidData".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache succesfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache sucesfully")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        let insertionError = insert((feed, timeStamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCacheFeedResult, file: StaticString = #file, line: UInt = #line)  {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    private func insert (_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timeStamp: cache.timestamp) { recivedInsertionError in
            insertionError = recivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
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
}
