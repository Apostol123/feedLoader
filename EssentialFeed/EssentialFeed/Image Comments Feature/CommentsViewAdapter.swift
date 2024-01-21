//
//  CommentsViewAdapter.swift
//  EssentialFeed
//
//  Created by Alex.personal on 21/1/24.
//

import Foundation
import Combine
import UIKit
import FeedLoader
import EssentialFeediOS

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map({ viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        }))
    }
}
