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

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedloaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedloaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }
}
