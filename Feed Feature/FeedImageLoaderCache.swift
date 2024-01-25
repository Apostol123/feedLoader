//
//  FeedImageLoaderCache.swift
//  FeedLoader
//
//  Created by Alex.personal on 2/12/23.
//

import Foundation

public protocol FeedImageCache {
     typealias SaveResult = Result<Void, Error>
     func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
