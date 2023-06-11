//
//  FeedLoader.swift
//  ImplementingMacOSFeedLoad
//
//  Created by alexandru.apostol on 8/6/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
