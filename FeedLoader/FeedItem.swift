//
//  FeedItem.swift
//  ImplementingMacOSFeedLoad
//
//  Created by alexandru.apostol on 8/6/23.
//

import Foundation

public struct FeedItem: Equatable {
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
