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
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primaryLoader = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load(completion: completion)
    }
}

final class RemoteWithLocalFallbackFeedLoaderTests: XCTestCase {

    func test_load_deliversRemoteFeedOnRemoteSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(primaryFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
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
