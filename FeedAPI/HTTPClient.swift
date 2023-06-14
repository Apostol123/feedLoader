//
//  HTTPClient.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 13/6/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion:@escaping (HTTPClientResult) -> Void)
}
