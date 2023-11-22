//
//  FeedLoaderStub.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 22/11/23.
//

import Foundation
import FeedLoader

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
