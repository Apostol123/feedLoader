//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 29/9/23.
//

import Foundation
import FeedLoader

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView: AnyObject {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
            return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                 tableName: "Feed",
                 bundle: Bundle(for: FeedPresenter.self),
                 comment: "Error message displayed when we can't load the image feed from the server")
        }
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.feedLoadingView = loadingView
        self.errorView = errorView
    }
    
    func feedDidStarLoadingFeed() {
        errorView.display(.noError)
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with: Error) {
        errorView.display(.error(message: feedLoadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
