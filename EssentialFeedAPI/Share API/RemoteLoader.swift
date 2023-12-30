//
//  RemoteLoader.swift
//  EssentialFeedAPI
//
//  Created by Alex.personal on 29/12/23.
//

import Foundation
import FeedLoader

public final class RemoteLoader<Resource> {
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    let client: HTTPClient
    let url: URL
    let mapper: Mapper

    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public init(client: HTTPClient, url: URL, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure:
                completion(.failure(Error.conectivity))
            case .success(let data, let response):
                completion(self.map(data, from: response))
            }
        })
    }

    private  func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
          return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

