//
//  XCTestCase+MemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 16/11/23.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
