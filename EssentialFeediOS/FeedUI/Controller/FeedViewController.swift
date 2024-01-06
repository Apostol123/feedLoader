//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 11/9/23.
//

import UIKit
import FeedLoader

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, FeedErrorView {
    public var delegate: FeedViewControllerDelegate?
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    
    private var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ cellController: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModel = cellController
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        if viewModel.message != nil {
            
        }
    }
    
    @IBAction
    private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellControllerForRow(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cencelControllerLoad(for: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllerForRow(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cencelControllerLoad(for: indexPath)
        }
    }
    
    private func cellControllerForRow(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func cencelControllerLoad(for indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}
