//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 19/9/23.
//

import UIKit
import FeedLoader

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let loader: FeedLoader?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc
    func refresh() {
        view.beginRefreshing()
        loader?.load { [weak self] result in
            if let feed  = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
