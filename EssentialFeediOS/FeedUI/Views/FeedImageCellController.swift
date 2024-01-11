//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit
import FeedLoader

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
    public typealias ResourceViewModel = UIImage
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let viewModel: FeedImageViewModel
    
    public init(viewModel: FeedImageViewModel,  delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
}

extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
    
    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageRetryButton.isHidden = !viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageContainer.isShimmering = !(viewModel.message == nil)
    }
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }
}
