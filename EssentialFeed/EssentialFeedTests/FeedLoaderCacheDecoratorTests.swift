//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 22/11/23.
//

import XCTest
import FeedLoader

final class FeedloaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedloaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = FeedLoaderStub(result: .failure(anyNSError()))
        let sut = FeedloaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    
    // MARK: - Helpers
    
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedFeed), .success(expectedFeed)):
                    XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                    
                case (.failure, .failure):
                    break
                    
                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }
                
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    

    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
}
