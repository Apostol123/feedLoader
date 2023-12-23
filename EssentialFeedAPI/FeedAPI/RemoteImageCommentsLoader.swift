//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 22/12/23.
//

import Foundation
import FeedLoader

public final class RemoteImageCommentsLoader: FeedLoader {
    let client: HTTPClient
    let url: URL

    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: {[weak self] result in
            guard self != nil else {return}
            switch result {
            case .failure:
                completion(.failure(Error.conectivity))
            case .success(let data, let response):
                completion(RemoteImageCommentsLoader.map(data, from: response))
            }
        })
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, response)
          return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}

