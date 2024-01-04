//
//  LoadResourcePresenter.swift
//  FeedLoader
//
//  Created by Alex.personal on 4/1/24.
//

import Foundation

public final class LoadResourcePresenter {
    private let errorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    public init(errorView: FeedErrorView, feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    private var feedLoadError: String {
            return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                 tableName: "Feed",
                 bundle: Bundle(for: FeedPresenter.self),
                 comment: "Error message displayed when we can't load the image feed from the server")
        }
    
    public func feedDidStarLoading() {
        errorView.display(FeedErrorViewModel(message: .none))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
