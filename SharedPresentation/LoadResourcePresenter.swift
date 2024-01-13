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
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private let errorView: ResourceErrorView
    private let feedLoadingView: ResourceLoadingView
    private let resourceView: View
    private let mapper: Mapper
    
    public init(errorView: ResourceErrorView, loadingView: ResourceLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.errorView = errorView
        self.feedLoadingView = loadingView
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
        errorView.display(ResourceErrorViewModel(message: .none))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(try mapper(resource))
            feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with: Error) {
        errorView.display(.error(message: loadError))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
