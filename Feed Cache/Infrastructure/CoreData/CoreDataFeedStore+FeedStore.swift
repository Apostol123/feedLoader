//
//  CoreDataFeedStore+FeedStore.swift
//  FeedLoader
//
//  Created by Alex.personal on 9/11/23.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {

    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }

}
