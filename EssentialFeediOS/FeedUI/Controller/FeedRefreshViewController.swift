//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    
    private let viewPresenter: FeedPresenter
    
    init(viewPresenter: FeedPresenter) {
        self.viewPresenter = viewPresenter
    }
    
    @objc
    func refresh() {
        viewPresenter.loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
