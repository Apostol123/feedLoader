//
//  FeedCache.swift
//  FeedLoader
//
//  Created by Alex.personal on 28/11/23.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

public final class FeedloaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map({ feed in
                self?.cache.save(feed, completion: {_ in})
                return feed
            }))
        }
    }
}
