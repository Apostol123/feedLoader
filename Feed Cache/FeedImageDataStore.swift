//
//  File.swift
//  FeedLoader
//
//  Created by Alex.personal on 9/11/23.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
