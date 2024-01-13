//
//  HTTPURLResponse+StatusCode.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 5/11/23.
//

import Foundation

public extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
