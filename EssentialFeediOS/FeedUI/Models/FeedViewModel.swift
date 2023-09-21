//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 21/9/23.
//

import Foundation
import FeedLoader

final class FeedViewModel {
    private let loader: FeedLoader?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        loader?.load { [weak self] result in
            if let feed  = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
