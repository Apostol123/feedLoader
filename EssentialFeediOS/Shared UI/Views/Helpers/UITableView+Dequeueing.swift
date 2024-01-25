//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 10/10/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
