//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 11/1/24.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datasourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable,_ datasource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.datasource = datasource
        self.delegate = datasource
        self.datasourcePrefetching = datasource
        self.id = id
    }
    
    public init(id: AnyHashable, dataSource: UITableViewDataSource) {
        self.datasource = dataSource
        self.delegate = nil
        self.datasourcePrefetching = nil
        self.id = id
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
