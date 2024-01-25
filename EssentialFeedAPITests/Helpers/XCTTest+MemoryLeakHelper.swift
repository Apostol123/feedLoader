//
//  XCTTest+MemoryLeakHelper.swift
//  EssentialFeedAPITests
//
//  Created by Alex.personal on 19/12/23.
//

import XCTest

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
