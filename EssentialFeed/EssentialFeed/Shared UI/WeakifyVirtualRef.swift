//
//  WeakifyVirtualRef.swift
//  EssentialFeed
//
//  Created by Alex.personal on 21/1/24.
//


import Combine
import UIKit
import FeedLoader
import EssentialFeediOS

public final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
    public func display(_ model: UIImage) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
