//
//  XCTTestCase+memoryLeakHelper.swift
//  FeedLoaderTests
//
//  Created by alexandru.apostol on 16/6/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
