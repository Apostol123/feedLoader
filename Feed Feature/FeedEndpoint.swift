//
//  FeedEndpoint.swift
//  FeedLoader
//
//  Created by Alex.personal on 22/1/24.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let afterImage):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host()
            components.path = baseURL.path() + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                afterImage.map({ URLQueryItem(name: "after_id", value: $0.id.uuidString)})
            ].compactMap({ $0 })
            return components.url!
        }
    }
}
