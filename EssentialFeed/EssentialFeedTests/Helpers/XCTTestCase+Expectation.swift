//
//  XCTTestCase+Expectation.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 22/11/23.
//

import Foundation
import XCTest
import FeedLoader

protocol FeedLoaderExpectation: XCTestCase {
    
}

extension FeedLoaderExpectation {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedFeed), .success(expectedFeed)):
                    XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                    
                case (.failure, .failure):
                    break
                    
                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }
                
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
}
