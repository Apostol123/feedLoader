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
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        loader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = {_ in }
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: loader)
        
        let feedController = ListViewController.makeWith(
            onRefresh: presentationAdapter.loadResource,
            title: FeedPresenter.title)
        
        let feedPresenter = LoadResourcePresenter(
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(loader: imageLoader,
                                          controller: feedController,
                                          selection: selection),
            mapper: {$0}
        )
        
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

private extension ListViewController {
    static func makeWith(onRefresh: @escaping () -> Void, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "FeedStoryboard", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.onRefresh = onRefresh
        feedController.title = title
        return feedController
    }
}

private final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(loader: @escaping (URL) -> FeedImageDataLoader.Publisher, controller: ListViewController, selection: @escaping (FeedImage) -> Void) {
        self.imageLoader = loader
        self.controller = controller
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.url)
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })

            adapter.presenter = LoadResourcePresenter(
                errorView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                resourceView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)

            return CellController(id: model, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            errorView: WeakRefVirtualProxy(loadMore),
            loadingView: WeakRefVirtualProxy(loadMore),
            resourceView: self,
            mapper: { $0 })


        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        controller?.display(feed, loadMoreSection)
    }
}

private struct InvalidImageDataError: Error {}


extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}

public extension Paginated {
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }
        
        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}
