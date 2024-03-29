//
//  HTTPSessionURLClient.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 17/6/23.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexcpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
            let wrapped: URLSessionTask

            func cancel() {
                wrapped.cancel()
            }
        }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
       let task = session.dataTask(with: url, completionHandler: {data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                   return (data, response)
                }
                else {
                    throw UnexcpectedValuesRepresentation()
                }
            })
        })
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
