//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 11/1/24.
//

import UIKit

public struct CellController {
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let datasourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(_ datasource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.datasource = datasource
        self.delegate = datasource
        self.datasourcePrefetching = datasource
    }
    
    public init(_ dataSource: UITableViewDataSource) {
        self.datasource = dataSource
        self.delegate = nil
        self.datasourcePrefetching = nil
    }
}
