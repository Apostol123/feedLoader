//
//  NullStore.swift
//  EssentialFeed
//
//  Created by Alex.personal on 23/1/24.
//

import Foundation
import FeedLoader

class NullStore: FeedStore & FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        return .none
    }
    
    func insert(_ data: Data, for url: URL) throws {
        
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
}
