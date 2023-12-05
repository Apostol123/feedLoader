//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex.personal on 2/11/23.
//

import Foundation

public struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
