//
//  FeedImageCellModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 26/9/23.
//

import Foundation
import FeedLoader

public final class FeedImagePresenter {
    public static func map(_ image:FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
