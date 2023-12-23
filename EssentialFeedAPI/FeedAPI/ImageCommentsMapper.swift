//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 23/12/23.
//

import Foundation
internal final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int {return 200}

    internal static func map(_ data: Data, _ respose: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard respose.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        return root.items
    }
}
