//
//  UIRefreshControllerHelper.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 10/1/24.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}

