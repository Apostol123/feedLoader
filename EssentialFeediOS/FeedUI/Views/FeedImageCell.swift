//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 12/9/23.
//

import UIKit

class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private (set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonWasTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc
    private func retryButtonWasTapped() {
        onRetry?()
    }

}
