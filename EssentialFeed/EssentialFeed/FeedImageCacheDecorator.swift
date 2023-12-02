//
//  FeedImageCacheDecorator.swift
//  EssentialFeed
//
//  Created by Alex.personal on 2/12/23.
//

import Foundation
import FeedLoader

public final class FeedImageCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageCache
    
    private var task: FeedImageDataLoaderTask?
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = decoratee.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.cache.save(data, for: url, completion: {_ in})
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
