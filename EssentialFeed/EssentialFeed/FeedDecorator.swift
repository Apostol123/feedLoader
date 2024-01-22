//
//  FeedDecorator.swift
//  EssentialFeed
//
//  Created by Alex.personal on 28/11/23.
//

import Foundation
import FeedLoader

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
                self?.cache.saveIgnoringResult(feed)
                return feed
            }))
        }
    }
}

