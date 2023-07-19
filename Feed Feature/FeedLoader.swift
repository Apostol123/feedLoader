//
//  FeedLoader.swift
//  ImplementingMacOSFeedLoad
//
//  Created by alexandru.apostol on 8/6/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
