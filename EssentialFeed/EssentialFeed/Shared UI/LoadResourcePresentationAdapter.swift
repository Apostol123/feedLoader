//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeed
//
//  Created by Alex.personal on 21/1/24.
//

import Combine
import UIKit
import FeedLoader
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: AnyCancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStarLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] resource in
            self?.presenter?.didFinishLoading(with: resource)
        }
        
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
       loadResource()
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
