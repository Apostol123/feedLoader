//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 22/11/23.
//

import XCTest
import FeedLoader

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderExpectation {

    func test_load_delivers_success_on_loader_success() {
        let feed = uniqueFeed()
        let sut = makeSUT(result: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliver_error_on_loader_failure() {
        let sut = makeSUT(result: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(result: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }

}
