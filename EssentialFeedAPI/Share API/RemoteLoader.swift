//
//  RemoteLoader.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 29/12/23.
//

import Foundation
import FeedLoader

public final class RemoteLoader: FeedLoader {
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
                completion(RemoteLoader.map(data, from: response))
            }
        })
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
          return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

