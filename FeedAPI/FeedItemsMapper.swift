//
//  FeedItemsMapper.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 13/6/23.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int {return 200}

    internal static func map(_ data: Data, _ respose: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard respose.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}

