//
//  Helpers.swift
//  FeedLoaderCacheIntegrationTests
//
//  Created by Alex.personal on 13/11/23.
//

import Foundation
import XCTest

extension XCTest {
    func anyURL() -> URL {
        return URL(string: "www.google.com")!
    }
    
    func anyData() -> Data {
        return Data()
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "www.google.com", code: 1)
    }
}
