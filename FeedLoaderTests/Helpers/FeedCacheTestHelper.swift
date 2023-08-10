//
//  FeedCacheTestHelper.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 10/8/23.
//

import Foundation
import FeedLoader

// MARK: - Helpers
func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let localFeedItems = models.map({LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    return (models, localFeedItems)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), url: URL(string: "www.google.com")!)
}


 func anyError() -> Error {
    NSError(domain: "any error", code: 1)
}

extension Date {
func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
}

func adding(seconds: TimeInterval) -> Date {
    return self + seconds
}
}
