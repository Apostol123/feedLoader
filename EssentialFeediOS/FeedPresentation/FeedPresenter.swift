//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 29/9/23.
//

import Foundation
import FeedLoader

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
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func feedDidStarLoadingFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with: Error) {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
