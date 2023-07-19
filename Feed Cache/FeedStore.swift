//
//  FeedStore.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 18/7/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalFeedItem: Equatable {
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }

    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
}
