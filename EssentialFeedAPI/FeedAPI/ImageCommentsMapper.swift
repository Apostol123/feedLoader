//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 23/12/23.
//

import Foundation
import FeedLoader
public final class ImageCommentsMapper {
    private struct Root: Decodable {
        private let items: [Item]
        
        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComments] {
            items.map {ImageComments(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username)}
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }

    private static var OK_200: Int {return 200}

    public static func map(_ data: Data, _ respose: HTTPURLResponse) throws -> [ImageComments] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard isOK(respose),
              let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.comments
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
