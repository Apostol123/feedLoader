//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 9/6/23.
//

import Foundation
import FeedLoader

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: FeedItemsMapper.map)
    }
}
