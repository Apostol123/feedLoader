//
//  ImageCommentController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 10/1/24.
//

import UIKit
import FeedLoader

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentsCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        
        return cell
    }
}
