//
//  LoadResourcePresenter.swift
//  FeedLoader
//
//  Created by Alex.personal on 4/1/24.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    private let errorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let resourceView: View
    private let mapper: Mapper
    
    public init(errorView: FeedErrorView, feedLoadingView: FeedLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.feedLoadingView = feedLoadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    private var loadError: String {
            return NSLocalizedString("GENERIC_VIEW_CONNECTION_ERROR",
                 tableName: "Shared",
                 bundle: Bundle(for: Self.self),
                 comment: "Error message displayed when we can't load the resource from the server")
        }
    
    public func didStarLoading() {
        errorView.display(FeedErrorViewModel(message: .none))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with: Error) {
        errorView.display(.error(message: loadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
