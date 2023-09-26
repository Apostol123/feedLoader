//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit
import FeedLoader

final class FeedImageCellModel {
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private var tasks: FeedImageDataLoaderTask?
    
    init(loader: FeedImageDataLoader, model: FeedImage) {
        self.imageLoader = loader
        self.model = model
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        model.description
    }
    
    var imageUrl: URL {
        return model.url
    }
    
    func preload() {
        tasks = imageLoader.loadImageData(from: model.url, completion: {_ in })
    }
    
    func cancelLoad() {
        tasks?.cancel()
    }
    
    func loadImage(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        self.tasks = imageLoader.loadImageData(from: model.url) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

final class FeedImageCellController {
    let cellModel: FeedImageCellModel
    
    init(cellModel: FeedImageCellModel) {
        self.cellModel = cellModel
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else {return}
            
            cellModel.loadImage { [weak cell] result in
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
        cellModel.preload()
    }
    
    func cancelLoad() {
        cellModel.cancelLoad()
    }
}

