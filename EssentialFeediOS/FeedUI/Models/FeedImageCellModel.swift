//
//  FeedImageCellModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 26/9/23.
//

import Foundation
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
