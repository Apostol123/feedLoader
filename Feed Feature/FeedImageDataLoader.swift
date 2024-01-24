//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import Foundation
import Combine


public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    func load(from url: URL) -> Publisher {
        return Deferred {
            Future { completion in
                if let data = try? self.loadImageData(from: url) {
                    completion(.success(data))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
