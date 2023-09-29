//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 20/9/23.
//

import UIKit
import FeedLoader

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(loader: loader)
        let refreshController  = FeedRefreshViewController(viewPresenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(loader: imageLoader, controller: feedController)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let feedImageCellModel = FeedImageCellModel(loader: loader, model: model)
                return FeedImageCellController(cellModel: feedImageCellModel)
            }
        }
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(loader: FeedImageDataLoader, controller: FeedViewController) {
        self.imageLoader = loader
        self.controller = controller
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            let feedImageCellModel = FeedImageCellModel(loader: imageLoader, model: model)
            return FeedImageCellController(cellModel: feedImageCellModel)
        }
    }
}
