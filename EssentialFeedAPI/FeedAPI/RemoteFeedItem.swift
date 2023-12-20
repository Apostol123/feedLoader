//
//  RemoteFeedItem.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 19/7/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
