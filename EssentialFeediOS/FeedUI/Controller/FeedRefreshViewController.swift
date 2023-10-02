//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit

protocol FeedRefereshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    @IBOutlet var view: UIRefreshControl?
    
    var delegate: FeedRefereshViewControllerDelegate?
    
    @IBAction
    func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
