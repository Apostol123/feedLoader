//
//  ImageCommentsComposer.swift
//  EssentialFeed
//
//  Created by Alex.personal on 21/1/24.
//

import Foundation
import Combine
import UIKit
import FeedLoader
import EssentialFeediOS

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

extension ListViewController {
    static func makeWithCommentsVC(onRefresh: @escaping () -> Void, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.onRefresh = onRefresh
        feedController.title = title
        return feedController
    }
}
