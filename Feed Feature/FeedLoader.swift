//
//  FeedLoader.swift
//  ImplementingMacOSFeedLoad
//
//  Created by alexandru.apostol on 8/6/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error> 

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
