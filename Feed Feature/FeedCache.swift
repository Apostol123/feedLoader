//
//  FeedCache.swift
//  FeedLoader
//
//  Created by Alex.personal on 28/11/23.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
