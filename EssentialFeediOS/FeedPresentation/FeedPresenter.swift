//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 29/9/23.
//

import Foundation
import FeedLoader

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView: AnyObject {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private let loader: FeedLoader?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    weak var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        loader?.load { [weak self] result in
            if let feed  = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.feedLoadingView?.display(isLoading: false)
        }
    }
}
