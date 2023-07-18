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

    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timeStamp: self.currentDate(), completion: {[weak self] error in
            guard let _ = self else {return}
            completion(error)
        })
    }
}
