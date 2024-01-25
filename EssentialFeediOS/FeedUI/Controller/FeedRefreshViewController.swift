//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit
import FeedLoader

protocol FeedRefereshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, ResourceLoadingView {
    
    @IBOutlet var view: UIRefreshControl?
    
    var delegate: FeedRefereshViewControllerDelegate?
    
    @IBAction
    func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
