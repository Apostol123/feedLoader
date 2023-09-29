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
    typealias Observer<T> = (T) -> Void
    private let loader: FeedLoader?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        loader?.load { [weak self] result in
            if let feed  = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
