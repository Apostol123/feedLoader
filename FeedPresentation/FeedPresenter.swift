//
//  FeedPresenter.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 4/11/23.
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}



public protocol FeedView: AnyObject {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let errorView: ResourceErrorView
    private let feedLoadingView: ResourceLoadingView
    private let feedView: FeedView
    
    public init(errorView: ResourceErrorView, feedLoadingView: ResourceLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
            return NSLocalizedString("GENERIC_VIEW_CONNECTION_ERROR",
                 tableName: "Feed",
                 bundle: Bundle(for: FeedPresenter.self),
                 comment: "Error message displayed when we can't load the image feed from the server")
        }
    
    public func feedDidStarLoadingFeed() {
        errorView.display(ResourceErrorViewModel(message: .none))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(Self.map(feed))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: feedLoadError))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
