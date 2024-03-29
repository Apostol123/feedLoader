//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import Foundation
import Combine


public protocol LocalFeedImageDataLoaderProtocol {
    func loadImageData(from url: URL) throws -> Data
}

public extension LocalFeedImageDataLoaderProtocol {
    typealias Publisher = AnyPublisher<Data, Error>
    func load(from url: URL) -> Publisher {
        return Deferred {
            Future { completion in
                completion(Result { try self.loadImageData(from: url) })
                
            }
        }.eraseToAnyPublisher()
    }
}


public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    func load(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)

            }
        }
        .handleEvents(receiveCancel: {task?.cancel()})
        .eraseToAnyPublisher()
    }
}

