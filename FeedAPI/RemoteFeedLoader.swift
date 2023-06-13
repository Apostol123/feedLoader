//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 9/6/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion:@escaping (HTTPClientResult) -> Void)
}

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
        client.get(from: url, completion: {result in
            switch result {
            case .failure(let error):
                completion(.failure(.conectivity))
            case .success(let data, let response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                        completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            }
        })
    }
}

private class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static var OK_200: Int {return 200}

    static func map(_ data: Data, _ respose: HTTPURLResponse) throws -> [FeedItem] {
        guard respose.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map({$0.item})
    }
}

