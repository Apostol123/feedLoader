//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit
import FeedLoader

final class FeedImageCellController {
    private var tasks: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else {return}
            
            self.tasks = imageLoader.loadImageData(from: model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        loadImage()
        
        cell.onRetry = loadImage
        
        return cell
    }
    
    func preload() {
        tasks = imageLoader.loadImageData(from: model.url, completion: {_ in })
    }
    
    deinit {
        tasks?.cancel()
    }
}

