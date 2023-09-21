//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 21/9/23.
//

import Foundation
import FeedLoader

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private let loader: FeedLoader?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
       onLoadingStateChange?(true)
        loader?.load { [weak self] result in
            if let feed  = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
