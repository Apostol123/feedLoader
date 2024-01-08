//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 20/9/23.
//

import Combine
import UIKit
import FeedLoader
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: {loader().dispatchOnMainQueue() })
       
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title) 
        
        let feedPresenter = LoadResourcePresenter(errorView: WeakRefVirtualProxy(feedController), feedLoadingView: WeakRefVirtualProxy(feedController), resourceView: FeedViewAdapter(loader: MainQueueDispatchDecorator(decoratee: imageLoader),
                                                                                                                                                                                      controller: feedController), mapper: FeedPresenter.map)
        
        presentationAdapter.presenter = feedPresenter
        
        
        return feedController
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
 
extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
    func display(_ model: UIImage) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(loader: FeedImageDataLoader, controller: FeedViewController) {
        self.imageLoader = loader
        self.controller = controller
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display( viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader.load(from: model.url)
            })
                        let view = FeedImageCellController(
                            viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model),
                            delegate: adapter)

                        adapter.presenter = LoadResourcePresenter(
                            errorView: WeakRefVirtualProxy(view),
                            feedLoadingView: WeakRefVirtualProxy(view),
                            resourceView: WeakRefVirtualProxy(view),
                            mapper: { data in
                                guard let image = UIImage(data: data) else {
                                    throw InvalidImageDataError()
                                }
                                return image
                            })

                        return view
        })
    }
}

private struct InvalidImageDataError: Error {}


private final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    private var cancellable: AnyCancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStarLoading()
        
        cancellable = loader().sink { [weak self] completion in
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

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)

            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
