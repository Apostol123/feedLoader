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
    private let calendar = Calendar(identifier: .gregorian)
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timeStamp: self.currentDate(), completion: {[weak self] error in
            guard let _ = self else {return}
            completion(error)
        })
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .found(let feed, timestamp: let date) where self.validate(date):
                completion(.success(feed.toModels()))
                
            case .found:
                self.store.deleteCachedFeed(completion: {_ in })
                completion(.success([]))
                
            case .empty:
                completion(.success([]))
            }
        })
    }

    public func validateCache() {
        store.retrieve(completion: {[weak self] result in
            switch result {
            case .failure(let error):
                self?.store.deleteCachedFeed(completion: {_ in})

            case .found(feed: let images, timestamp: let date):
                break

            case .empty:
                break
            }
        })

    }

    private var maxCacheAgeInDays: Int {
        return 7
    }

    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {return false}
        return currentDate() < maxCacheAge
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
