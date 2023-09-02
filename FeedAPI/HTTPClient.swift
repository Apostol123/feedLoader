//
//  HTTPClient.swift
//  FeedLoader
//
//  Created by alexandru.apostol on 13/6/23.
//

import Foundation

public protocol HTTPClient {
    typealias Result =  Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion:@escaping (Result) -> Void)
}
