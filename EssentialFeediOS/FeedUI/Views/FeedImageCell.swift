//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 12/9/23.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var  locationLabel: UILabel!
    @IBOutlet private(set) public var  descriptionLabel: UILabel!
    @IBOutlet private(set) public var  feedImageContainer: UIView!
    @IBOutlet private(set) public var  feedImageView: UIImageView!
    @IBOutlet private(set) public var  feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction
    private func retryButtonWasTapped() {
        onRetry?()
    }
}
