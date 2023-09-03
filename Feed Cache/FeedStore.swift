//
//  FeedStore.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 18/7/23.
//

import Foundation

public typealias RetrieveCacheFeedResult = Swift.Result<CachedFeed?, Error>

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionError = Result<Void, Error>
    typealias DeletionCompletion = (DeletionError) -> Void
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrieveCacheFeedResult) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
