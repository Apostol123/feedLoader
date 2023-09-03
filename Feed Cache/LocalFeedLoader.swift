//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 18/7/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
 
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed {[weak self] deletionResult in
            guard let self = self else {return}
            switch deletionResult {
            case let .failure(error):
                completion(.failure(error))
            case .success:
                self.cache(feed, with: completion)
            }
        }
    }
}


extension LocalFeedLoader {

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timeStamp: self.currentDate(), completion: {[weak self] error in
            guard let _ = self else {return}
            completion(error)
        })
    }
}


extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success:
                completion(.success([]))
            }
        })
    }
}

extension LocalFeedLoader {

    public func validateCache() {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: {_ in})

            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: {_ in })

            case .success(.none):
                break

            case .success:
                break
            }
        })

    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
