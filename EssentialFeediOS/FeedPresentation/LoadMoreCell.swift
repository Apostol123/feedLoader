//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 21/1/24.
//

import UIKit
import FeedLoader

public class LoadMoreCell: UITableViewCell {
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return spinner
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        return label
    }()

    public var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }

    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }
}

