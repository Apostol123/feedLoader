//
//  HTTPClient.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 13/6/23.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result =  Swift.Result<(Data, HTTPURLResponse), Error>
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
