//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 2/11/23.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    var hasLocation: Bool {
        return location != nil
    }
}
