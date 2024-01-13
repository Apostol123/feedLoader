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
    
    public static func feedComposedWith(loader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: {loader().dispatchOnMainQueue() })
       
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        
        let feedController = ListViewController.makeWith(
            onRefresh: presentationAdapter.loadResource,
            title: FeedPresenter.title)
        
        let feedPresenter = LoadResourcePresenter(
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(loader: imageLoader,
                                          controller: feedController),
            mapper: FeedPresenter.map
        )
        
        presentationAdapter.presenter = feedPresenter
        
        
        return feedController
    }
}

public final class CommentsUIComposer {
    private init() {}
    
    public static func commentsComposedWith(loader: @escaping () -> AnyPublisher<[ImageComments], Error>) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[ImageComments], CommentsViewAdapter>(loader: {loader().dispatchOnMainQueue() })
       
        
        
        let commentViewController = ListViewController.makeWithCommentsVC(
            onRefresh: presentationAdapter.loadResource,
            title: ImageCommentsPresenter.title)
        
        let feedPresenter = LoadResourcePresenter(
            errorView: WeakRefVirtualProxy(commentViewController),
            loadingView: WeakRefVirtualProxy(commentViewController),
            resourceView: CommentsViewAdapter(
                controller: commentViewController
            ),
            mapper: {ImageCommentsPresenter.map($0)}
        )
        
        presentationAdapter.presenter = feedPresenter
        
        
        return commentViewController
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

private extension ListViewController {
    static func makeWith(onRefresh: @escaping () -> Void, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.onRefresh = onRefresh
        feedController.title = title
        return feedController
    }
    
    static func makeWithCommentsVC(onRefresh: @escaping () -> Void, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.onRefresh = onRefresh
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
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(loader: @escaping (URL) -> FeedImageDataLoader.Publisher, controller: ListViewController) {
        self.imageLoader = loader
        self.controller = controller
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display( viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(model.url)
            })
                        let view = FeedImageCellController(
                            viewModel: FeedImagePresenter.map(model),
                            delegate: adapter)

                        adapter.presenter = LoadResourcePresenter(
                            errorView: WeakRefVirtualProxy(view),
                            loadingView: WeakRefVirtualProxy(view),
                            resourceView: WeakRefVirtualProxy(view),
                            mapper: { data in
                                guard let image = UIImage(data: data) else {
                                    throw InvalidImageDataError()
                                }
                                return image
                            })

            return CellController(id: model, view)
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


private final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map({ viewModel in
            CellController(id: viewModel, dataSource: ImageCommentCellController(model: viewModel))
        }))
    }
}
