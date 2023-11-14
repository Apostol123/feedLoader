//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 14/11/23.
//

import XCTest
import FeedLoader

class FeedLoaderWithFallbackComposite: FeedLoader {
    let primaryLoader: FeedLoader
    let fallbackLoder: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primaryLoader = primary
        self.fallbackLoder = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success(_):
                completion(result)
                
            case .failure(_):
                self?.fallbackLoder.load(completion: completion)
            }
        }
    }
}

final class RemoteWithLocalFallbackFeedLoaderTests: XCTestCase {

    func test_load_deliversRemoteFeedOnRemoteSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case .success(let receivedResult):
               XCTAssertEqual(receivedResult, primaryFeed)
            case .failure(_):
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for loaded completion")
        
        sut.load { result in
            switch result {
            case .success(let receivedResult):
                XCTAssertEqual(receivedResult, fallbackFeed)
            case .failure(_):
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "www.google.com", code: 1)
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
