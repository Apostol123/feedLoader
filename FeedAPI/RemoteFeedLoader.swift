//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 9/6/23.
//

import Foundation

public final class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url, completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                completion(.failure(.conectivity))
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, response))
            }
        })
    }
}
