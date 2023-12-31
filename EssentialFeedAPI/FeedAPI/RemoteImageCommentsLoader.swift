//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 22/12/23.
//

import Foundation
import FeedLoader

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComments]>

public extension RemoteImageCommentsLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
