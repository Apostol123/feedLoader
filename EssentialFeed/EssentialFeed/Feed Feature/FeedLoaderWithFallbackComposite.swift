//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialFeed
//
//  Created by Alex.personal on 15/11/23.
//

import Foundation
import FeedLoader

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primaryLoader: FeedLoader
    private let fallbackLoder: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primaryLoader = primary
        self.fallbackLoder = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primaryLoader.load { [weak self] result in
            switch result {
            case .success(_):
                completion(result)
                
            case .failure(_):
                self?.fallbackLoder.load(completion: completion)
            }
        }
    }
}
