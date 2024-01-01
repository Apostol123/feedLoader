//
//  FeedItemsMapper.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 13/6/23.
//

import Foundation
import FeedLoader

public final class FeedItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable {
            internal let id: UUID
            internal let description: String?
            internal let location: String?
            internal let image: URL
        }
        
        var images: [FeedImage] {
            items.map {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
        }
    }

    private static var OK_200: Int {return 200}
    

    public static func map(_ data: Data, _ respose: HTTPURLResponse) throws -> [FeedImage] {
        guard respose.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.images
    }
}
