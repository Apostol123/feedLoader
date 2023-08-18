//
//  LocalFeedItems.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 19/7/23.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public init(id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
}
