//
//  LoadResourcePresenter.swift
//  FeedLoader
//
//  Created by Alex.personal on 4/1/24.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    private let errorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let resourceView: ResourceView
    private let mapper: Mapper
    
    public init(errorView: FeedErrorView, feedLoadingView: FeedLoadingView, resourceView: ResourceView, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.feedLoadingView = feedLoadingView
        self.resourceView = resourceView
        self.mapper = mapper
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
    
    public func didFinishLoadingFeed(with resource: String) {
        resourceView.display(mapper(resource))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
