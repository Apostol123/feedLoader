////
////  FeedLoaderCacheIntegrationTests.swift
////  FeedLoaderCacheIntegrationTests
////
////  Created by Alex.personal on 26/8/23.
////
//
//import XCTest
//import FeedLoader
//
//final class FeedLoaderCacheIntegrationTests: XCTestCase {
//    func test_load_deliversNoItemsOnEmptyCache() {
//        let sut = makeSUT()
//
//        let exp = expectation(description: "WaitForLoadCompletion")
//
//        sut.load { result in
//            switch result {
//            case let .success(imageFeed):
//                XCTAssertEqual(imageFeed, [], "Expected empty cache")
//
//            case let .failure(error):
//                XCTFail("Expected successful feed result, got \(error) instead")
//            }
//            exp.fulfill()
//
//        }
//        wait(for: [exp], timeout: 1.0)
//    }
//
//    //MARK: Helpers
//    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
//        let storeBundle = Bundle(for: CoreDataFeedStore.self)
//        let storeURL = testSpecificStoreURL()
//        let store = try! CoreDataFeedStore(storeURL: storeURL, bunlde: storeBundle)
//        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
//        trackForMemoryLeaks(store, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//
//    private func testSpecificStoreURL() -> URL {
//        return cachesDirectory.appending(path: "\(type(of: self)).store")
//    }
//
//    private func cachesDirectory() -> URL {
//        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//    }
//
//}
